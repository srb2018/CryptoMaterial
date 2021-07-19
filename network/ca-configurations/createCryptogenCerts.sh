export PATH=${PWD}/../bin:$PATH

source scripts/utils.sh

infoln "Creating ISTC Org1 Identities"
cryptogen generate --config=${PWD}/ca-configurations/istc/cryptogenConfig/crypto-config-istc.yaml --output=${PWD}/ca-configurations/istc

infoln "Creating Orderer Org Identities"
cryptogen generate --config=${PWD}/ca-configurations/istc/cryptogenConfig/crypto-config-orderer.yaml --output=${PWD}/ca-configurations/istc
