'use strict';

const express = require("express");
const router = express.Router();
const bodyParser = require("body-parser");
const { Wallets, Gateway, DefaultEventHandlerStrategies } = require('fabric-network');
const commonUtils = require('./commonUtils');
const HLFService = require('./hlfService');

router.use(bodyParser.urlencoded({ extended: true }));
router.use(bodyParser.json());

const invokeTransaction = async (channelName, chaincodeName, chanincodeFun, args, username, userOrg, transactionType) => {
    try {
        /** Load the network configuration */
        let ccp = await HLFService.getCCP(userOrg);

        /** Create a new file system based wallet for managing identities. */
        const walletPath = await HLFService.getWalletPath(userOrg)
        const wallet = await Wallets.newFileSystemWallet(walletPath);

        /** Get the userIdentity details from the wallet. */
        let identity = await wallet.get(username);
        if (!identity) {
            commonUtils.logger.error(`An identity for the user ${username} does not exist in the wallet, so registering user`);
            return;
        }

        const connectOptions = {
            wallet, identity: username, discovery: { enabled: true, asLocalhost: true },
            eventHandlerOptions: {
                commitTimeout: 100,
                strategy: DefaultEventHandlerStrategies.NETWORK_SCOPE_ALLFORTX
            }
        }

        /** Create a new gateway for connecting to our peer node. */
        const gateway = new Gateway();
        await gateway.connect(ccp, connectOptions);

        const network = await gateway.getNetwork(channelName);  // Get the network (channel) our contract is deployed to.
        const contract = network.getContract(chaincodeName);    // Get the contract from the network. 

        var result;
        var message;
        switch (transactionType) {
            case "invoke":
                result = await contract.submitTransaction(chanincodeFun, "["+args+"]");
                message = `Successfully created tea lot`;
                break;
            case "query":
                result = await contract.evaluateTransaction(chanincodeFun, args);
                message = `Successfully update tea lot`;
                break;
            default:
                commonUtils.logger.fatal(`function is not avaiable ${chanincodeFun}`)
                return `function is not avaiable ${chanincodeFun}`;
        }
        await gateway.disconnect();

        let response = {
            message: message,
            result: result.toString()
        }

        return response;
    } catch (error) {
        commonUtils.logger.error(`Failed to submit transaction: ${error}`);
    }
}

router.post("/createTeaLot", async function (req, res) {
    try {
        let result = await invokeTransaction("teachannel", "ISTC", "CreateTeaLot", JSON.stringify(JSON.stringify(req.body)), req.username, req.orgname, "invoke");
        res.send(result);
    } catch (err) {
        res.status(500).send(err);
    }
});

router.post("/updateTeaLot", async function (req, res) {

    try {
        let result = await invokeTransaction("teachannel", "ISTC", "updateTeaLot", JSON.stringify(req.body), req.username, req.orgname, "invoke");
        res.send(result);
    } catch (err) {
        res.status(500).send(err);
    }
});

router.post("/createTeaPacket", async function (req, res) {
    try {
        let result = await invokeTransaction("teachannel", "ISTC", "createTeaPacket", JSON.stringify(req.body), req.username, req.orgname, "invoke");
        res.send(result);
    } catch (err) {
        res.status(500).send(err);
    }
});

router.post("/updateTeaPacket", async function (req, res) {
    try {
        let result = await invokeTransaction("teachannel", "ISTC", "updateTeaPacket", JSON.stringify(req.body), req.username, req.orgname, "invoke");
        res.send(result);
    } catch (err) {
        res.status(500).send(err);
    }
});

router.post("/initiateTeaTaste", async function (req, res) {
    try {
        let result = await invokeTransaction("teachannel", "ISTC", "initiateTeaTaste", JSON.stringify(req.body), req.username, req.orgname, "invoke");
        res.send(result);
    } catch (err) {
        res.status(500).send(err);
    }
});

router.post("/updateTeaTaste", async function (req, res) {
    try {
        let result = await invokeTransaction("teachannel", "ISTC", "updateTeaTaste", JSON.stringify(req.body), req.username, req.orgname, "invoke");
        res.send(result);
    } catch (err) {
        res.status(500).send(err);
    }
});

router.post("/initiateLabTest", async function (req, res) {
    try {
        let result = await invokeTransaction("teachannel", "ISTC", "initiateLabTest", JSON.stringify(req.body), req.username, req.orgname, "invoke");
        res.send(result);
    } catch (err) {
        res.status(500).send(err);
    }
});

router.post("/updateLabResult", async function (req, res) {
    try {
        let result = await invokeTransaction("teachannel", "ISTC", "updateLabResult", JSON.stringify(req.body), req.username, req.orgname, "invoke");
        res.send(result);
    } catch (err) {
        res.status(500).send(err);
    }
});

router.post("/getTeaLotHistory", async function (req, res) {
    try {
        let result = await invokeTransaction("teachannel", "ISTC", "getTeaLotHistory", JSON.stringify(req.body), req.username, req.orgname, "query");
        res.send(result);
    } catch (err) {
        res.status(500).send(err);
    }
});

router.post("/getTeaLot", async function (req, res) {
    try {
        let result = await invokeTransaction("teachannel", "ISTC", "getTeaLot", JSON.stringify(req.body), req.username, req.orgname, "query");
        res.send(result);
    } catch (err) {
        res.status(500).send(err);
    }
});

router.post("/getTeaPacket", async function (req, res) {
    try {
        let result = await invokeTransaction("teachannel", "ISTC", "getTeaPacket", JSON.stringify(req.body), req.username, req.orgname, "query");
        res.send(result);
    } catch (err) {
        res.status(500).send(err);
    }
});

router.post("/getTeaPacketHistory", async function (req, res) {
    try {
        let result = await invokeTransaction("teachannel", "ISTC", "getTeaPacketHistory", JSON.stringify(req.body), req.username, req.orgname, "query");
        res.send(result);
    } catch (err) {
        res.status(500).send(err);
    }
});

router.post("/queryAllTeaLots", async function (req, res) {
    try {
        let result = await invokeTransaction("teachannel", "ISTC", "queryAllTeaLots", JSON.stringify(req.body), req.username, req.orgname, "query");
        res.send(result);
    } catch (err) {
        res.status(500).send(err);
    }
});

router.post("/queryAllTeaPackets", async function (req, res) {
    try {
        let result = await invokeTransaction("teachannel", "ISTC", "queryAllTeaPackets", JSON.stringify(req.body), req.username, req.orgname, "query");
        res.send(result);
    } catch (err) {
        res.status(500).send(err);
    }
});

module.exports = router