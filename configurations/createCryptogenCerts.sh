export PATH=${PWD}/../bin:$PATH
echo "Creating ISTC certs"
cryptogen generate --config=${PWD}/istc/cryptogenConfig/crypto-config-istc.yaml --output=${PWD}/istc/config/cryptogen

echo "Creating Admin certs"
cryptogen generate --config=${PWD}/istc/cryptogenConfig/crypto-config-orderer.yaml --output=${PWD}/istc/config/cryptogen