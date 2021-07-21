'use strict';

const { Wallets, Gateway, DefaultEventHandlerStrategies } = require('fabric-network');
const commonUtils = require('./commonUtils');
const HLFService = require('./hlfService');

const invokeTransaction = async (channelName, chaincodeName, chanincodeFun, args, username, userOrg, transientData) => {
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
        var privatePayload;
        switch (chanincodeFun) {
            case "createTeaLot":
                result = await contract.submitTransaction(chanincodeFun, args);
                message = `Successfully created tea lot`;
                break;
            case "updateTeaLot":
                result = await contract.submitTransaction(chanincodeFun, args);
                message = `Successfully update tea lot`;
                break;
            case "createTeaPacket":
                result = await contract.submitTransaction(chanincodeFun, args);
                message = `Successfully created Tea Packet`;
                break;
            case "updateTeaPacket":
                result = await contract.submitTransaction(chanincodeFun, args);
                message = `Successfully updated Tea Packet`;
                break;
            case "initiateTeaTaste":
                result = await contract.submitTransaction(chanincodeFun, args);
                message = `Successfully initiated Tea Taste`;
                break;
            case "updateTeaTaste":
                result = await contract.submitTransaction(chanincodeFun, args);
                message = `Successfully updated Tea Taste`;
                break;
            case "initiateLabTest":
                result = await contract.submitTransaction(chanincodeFun, args);
                message = `Successfully initiated Lab Test`;
                break;
            case "updateLabResult":
                result = await contract.submitTransaction(chanincodeFun, args);
                message = `Successfully updated Lab Test`;
                break;
            case "getTeaLot":
                result = await contract.evaluateTransaction(chanincodeFun, args);
                message = `Successfully query the tea lot`;
                break;
            case "getTeaLotHistory":
                result = await contract.evaluateTransaction(chanincodeFun, args);
                message = `Successfully query the tea Lot History`;
                break;
            case "getTeaPacket":
                result = await contract.evaluateTransaction(chanincodeFun, args);
                message = `Successfully query the tea Packet`;
                break;
            case "getTeaPacketHistory":
                result = await contract.evaluateTransaction(chanincodeFun, args);
                message = `Successfully query the Tea Packet History`;
                break;
            case "queryAllTeaLots":
                result = await contract.evaluateTransaction(chanincodeFun);
                message = `Successfully query All TeaLots`;
                break;
            case "queryAllTeaPackets":
                result = await contract.evaluateTransaction(chanincodeFun);
                message = `Successfully query All TeaPackets`;
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

module.exports = {
    invokeTransaction: invokeTransaction
}