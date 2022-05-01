
const PrivateKeyProvider = require("truffle-privatekey-provider");
const privateKey = 'C7F038F9A424D7604EE05A53FED9920F4859C4D283ED9385B93913C13266571C';

module.exports = {
    compilers: {
        solc: {
            version: "0.8.13",
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 300
                }
            },
        }
    },
    networks: {
        development: {
            host: "127.0.0.1",
            port: 8545,
            network_id: 5777
        },
        matic: {
            provider: () => new PrivateKeyProvider(
                privateKey,
                'https://testnetv3.matic.network'
            ),
            network_id: 15001,
            gasPrice: '0x0',
            confirmations: 2,
            timeoutBlocks: 200,
            skipDryRun: true
        },
        mumbai: {
            provider: () => new PrivateKeyProvider(
                privateKey,
                'https://rpc-mumbai.matic.today'
            ),
            network_id: 80001,
            confirmations: 1,
            timeoutBlocks: 300,
            skipDryRun: true
        },
        maticmain: {
            provider: () => new PrivateKeyProvider(
                privateKey,
                'https://rpc-mainnet.matic.network'
            ),
            network_id: 137,
            confirmations: 1,
            timeoutBlocks: 300,
            skipDryRun: true
        }
    },
    mocha: {
        useColors: true,
        reporter: "eth-gas-reporter",
        reporterOptions: {
            currency: "USD",
            gasPrice: 10
        }
    }
};
