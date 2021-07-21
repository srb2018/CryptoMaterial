'use strict';

const path = require('path');
const fs = require('fs');

const getCCP = async (org) => {
    var ccpPath;
    if (org == "ISTCOrg1") {
        ccpPath = path.resolve(__dirname, '..', '..', 'network', 'ca-configurations', 'peerOrganizations', 'istcorg1.istc.com', 'connection-istcorg1.json');
    } else if (org == "Org2") {
        ccpPath = path.resolve(__dirname, '..', '..', 'network', 'ca-configurations', 'peerOrganizations', 'istcorg2.istc.com', 'connection-istcorg2.json');
    } else { return null };
    const ccpJSON = fs.readFileSync(ccpPath, 'utf8');
    const ccp = JSON.parse(ccpJSON);
    return ccp;
}

const getCAUrl = async (org, ccp) => {
    let caUrl;
    switch (org) {
        case "ISTCOrg1":
            caUrl = ccp.certificateAuthorities['ca.istcorg1.istc.com'].url;
            break;
        case "Org2":
            caUrl = ccp.certificateAuthorities['ca.istcorg2.istc.com'].url;
            break;
        default:
            return null;
    }
    return caUrl;
}

const getCaInfo = async (org, ccp) => {
    let caInfo;
    switch (org) {
        case 'ISTCOrg1':
            caInfo = ccp.certificateAuthorities['ca.istcorg1.istc.com'];
            break;
        case 'Org2':
            caInfo = ccp.certificateAuthorities['ca.istcorg2.istc.com'];
            break;
        default:
            return null;
    };
    return caInfo
}

const getWalletPath = async (org) => {
    let walletPath;
    switch (org) {
        case 'ISTCOrg1':
            walletPath = path.join(process.cwd(), 'wallet');
            break;
        case 'Org2':
            walletPath = path.join(process.cwd(), 'wallet');
            break;
        default:
            return null;
    }
    return walletPath;
}

const createX509Identity = async (org, enrollment) => {
    let x509Identity = {
        credentials: {
            certificate: enrollment.certificate,
            privateKey: enrollment.key.toBytes(),
        },
        mspId: org + 'MSP',
        type: 'X.509',
    };
    return x509Identity;
}

const getAffiliation = async (org) => {
    return org == "ISTCOrg1" ? 'org1.department1' : 'org2.department1'
}

module.exports = {
    getCCP: getCCP,
    getCAUrl: getCAUrl,
    getCaInfo: getCaInfo,
    getWalletPath: getWalletPath,
    createX509Identity: createX509Identity,
    getAffiliation: getAffiliation
}