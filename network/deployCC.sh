#!/bin/bash

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/../config
export VERBOSE=false

# Import's scripts
. scripts/utils.sh
. scripts/envVar.sh

CHANNEL_NAME="teachannel"
CC_NAME="ISTC"
CC_SRC_PATH="../chaincode/istc/"
CC_INIT_FCN="Init"
CC_VERSION="1.0"
CC_SEQUENCE="1"
CC_END_POLICY="NA"
CC_COLL_CONFIG="NA"
CC_SRC_LANGUAGE="go"
DELAY=3
MAX_RETRY=5

println "executing with the following"
println "- CHANNEL_NAME: ${C_GREEN}${CHANNEL_NAME}${C_RESET}"
println "- CC_NAME: ${C_GREEN}${CC_NAME}${C_RESET}"
println "- CC_SRC_PATH: ${C_GREEN}${CC_SRC_PATH}${C_RESET}"
println "- CC_VERSION: ${C_GREEN}${CC_VERSION}${C_RESET}"
println "- CC_SEQUENCE: ${C_GREEN}${CC_SEQUENCE}${C_RESET}"
println "- CC_END_POLICY: ${C_GREEN}${CC_END_POLICY}${C_RESET}"
println "- CC_INIT_FCN: ${C_GREEN}${CC_INIT_FCN}${C_RESET}"
println "- DELAY: ${C_GREEN}${DELAY}${C_RESET}"
println "- MAX_RETRY: ${C_GREEN}${MAX_RETRY}${C_RESET}"
println "- VERBOSE: ${C_GREEN}${VERBOSE}${C_RESET}"

CC_SRC_LANGUAGE=$(echo "$CC_SRC_LANGUAGE" | tr [:upper:] [:lower:])

if [ "$CC_SRC_LANGUAGE" = "go" ]; then
    CC_RUNTIME_LANGUAGE=golang

    infoln "Vendoring Go dependencies at $CC_SRC_PATH"
    pushd $CC_SRC_PATH
    GO111MODULE=on go mod vendor
    popd
    successln "Finished vendoring Go dependencies"
else
    fatalln "The chaincode language ${CC_SRC_LANGUAGE} is not supported by this script. Supported chaincode languages are: go"
    exit 1
fi

INIT_REQUIRED="--init-required"
if [ "$CC_INIT_FCN" = "NA" ]; then
    INIT_REQUIRED=""
fi

if [ "$CC_END_POLICY" = "NA" ]; then
    CC_END_POLICY=""
else
    CC_END_POLICY="--signature-policy $CC_END_POLICY"
fi

function packageChaincode() {
    set -x
    peer lifecycle chaincode package ${CC_NAME}.tar.gz --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} --label ${CC_NAME}_${CC_VERSION} >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Chaincode packaging has failed"
    successln "Chaincode is packaged"
}

function installChaincode() {
    ORG=$1
    setGlobals $ORG
    set -x
    peer lifecycle chaincode install ${CC_NAME}.tar.gz >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Chaincode installation on peer0.istcorg${ORG} has failed"
    successln "Chaincode is installed on peer0.istcorg${ORG}"
}

function queryInstalled() {
    ORG=$1
    setGlobals $ORG
    set -x
    peer lifecycle chaincode queryinstalled >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${CC_VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    verifyResult $res "Query installed on peer0.istcorg${ORG} has failed"
    successln "Query installed successful on peer0.istcorg${ORG} on channel"
}

function approveForMyOrg() {
    ORG=$1
    setGlobals $ORG
    set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.istc.com --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --package-id ${PACKAGE_ID} --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} ${CC_END_POLICY} ${CC_COLL_CONFIG} >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Chaincode definition approved on peer0.org${ORG} on channel '$CHANNEL_NAME' failed"
    successln "Chaincode definition approved on peer0.org${ORG} on channel '$CHANNEL_NAME'"
}

function checkCommitReadiness() {
    ORG=$1
    shift 1
    setGlobals $ORG
    infoln "Checking the commit readiness of the chaincode definition on peer0.istcorg${ORG} on channel '$CHANNEL_NAME'..."
    local rc=1
    local COUNTER=1
    # continue to poll
    # we either get a successful response, or reach MAX RETRY
    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
        sleep $DELAY
        infoln "Attempting to check the commit readiness of the chaincode definition on peer0.istcorg${ORG}, Retry after $DELAY seconds."
        set -x
        peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} ${CC_END_POLICY} ${CC_COLL_CONFIG} --output json >&log.txt
        res=$?
        { set +x; } 2>/dev/null
        let rc=0
        for var in "$@"; do
            grep "$var" log.txt &>/dev/null || let rc=1
        done
        COUNTER=$(expr $COUNTER + 1)
    done
    cat log.txt
    if test $rc -eq 0; then
        infoln "Checking the commit readiness of the chaincode definition successful on peer0.istcorg${ORG} on channel '$CHANNEL_NAME'"
    else
        fatalln "After $MAX_RETRY attempts, Check commit readiness result on peer0.istcorg${ORG} is INVALID!"
    fi
}

function commitChaincodeDefinition() {
    parsePeerConnectionParameters $@
    res=$?
    verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

    # while 'peer chaincode' command can get the orderer endpoint from the
    # peer (if join was successful), let's supply it directly as we know
    # it using the "-o" option
    set -x
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.istc.com --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} $PEER_CONN_PARMS --version ${CC_VERSION} --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} ${CC_END_POLICY} ${CC_COLL_CONFIG} >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Chaincode definition commit failed on peer0.org${ORG} on channel '$CHANNEL_NAME' failed"
    successln "Chaincode definition committed on channel '$CHANNEL_NAME'"
}

function queryCommitted() {
    ORG=$1
    setGlobals $ORG
    EXPECTED_RESULT="Version: ${CC_VERSION}, Sequence: ${CC_SEQUENCE}, Endorsement Plugin: escc, Validation Plugin: vscc"
    infoln "Querying chaincode definition on peer0.org${ORG} on channel '$CHANNEL_NAME'..."
    local rc=1
    local COUNTER=1
    # continue to poll
    # we either get a successful response, or reach MAX RETRY
    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
        sleep $DELAY
        infoln "Attempting to Query committed status on peer0.org${ORG}, Retry after $DELAY seconds."
        set -x
        peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME} >&log.txt
        res=$?
        { set +x; } 2>/dev/null
        test $res -eq 0 && VALUE=$(cat log.txt | grep -o '^Version: '$CC_VERSION', Sequence: [0-9]*, Endorsement Plugin: escc, Validation Plugin: vscc')
        test "$VALUE" = "$EXPECTED_RESULT" && let rc=0
        COUNTER=$(expr $COUNTER + 1)
    done
    cat log.txt
    if test $rc -eq 0; then
        successln "Query chaincode definition successful on peer0.org${ORG} on channel '$CHANNEL_NAME'"
    else
        fatalln "After $MAX_RETRY attempts, Query chaincode definition result on peer0.org${ORG} is INVALID!"
    fi
}

function chaincodeInvokeInit() {
    parsePeerConnectionParameters $@
    res=$?
    verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

    # while 'peer chaincode' command can get the orderer endpoint from the
    # peer (if join was successful), let's supply it directly as we know
    # it using the "-o" option
    set -x
    fcn_call='{"function":"'${CC_INIT_FCN}'","Args":[]}'
    infoln "invoke fcn call:${fcn_call}"
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.istc.com --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} $PEER_CONN_PARMS --isInit -c ${fcn_call} >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Invoke execution on $PEERS failed "
    successln "Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME'"
}


## package the chaincode
packageChaincode

## Install chaincode on peer0.istcorg1 
infoln "Installing chaincode on peer0.istcorg1"
installChaincode 1

## query whether the chaincode is installed
infoln "Query Install chaincode on peer0.istcorg1"
queryInstalled 1

## approve the definition for org1
infoln "Approve the Definition for istcorg1"
approveForMyOrg 1

## check whether the chaincode definition is ready to be committed
infoln "Check Commit Readiness for ISTCOrg1MSP"
checkCommitReadiness 1 "\"ISTCOrg1MSP\": true"

## now that we know for sure both orgs have approved, commit the definition
infoln "Commit Chaincode Definition for istcorg1"
commitChaincodeDefinition 1

## query on both orgs to see that the definition committed successfully
infoln "Query Commit Chaincode for istcorg1"
queryCommitted 1

if [ "$CC_INIT_FCN" = "NA" ]; then
    infoln "Chaincode initialization is not required"
else
    chaincodeInvokeInit 1
fi

exit 0


