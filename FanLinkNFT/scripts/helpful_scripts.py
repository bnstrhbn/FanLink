from brownie import (
    network,
    accounts,
    config,
)
from web3 import Web3

NON_FORKED_LOCAL_BLOCKCHAIN_ENVIRONMENTS = [
    "hardhat",
    "development",
    "ganache",
    "ganache-local",
]
LOCAL_BLOCKCHAIN_ENVIRONMENTS = NON_FORKED_LOCAL_BLOCKCHAIN_ENVIRONMENTS + [
    "mainnet-fork",
    "binance-fork",
    "matic-fork",
]


DECIMALS = 18
INITIAL_VALUE = Web3.toWei(2000, "ether")


def get_account(index=None, id=None):
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        if index:
            return accounts[index]
        else:
            return accounts[0]
    if network.show_active() == "kovan":
        if index == None:
            return accounts.add(config["wallets"]["from_key"])
        else:
            return accounts.add(config["wallets"]["from_key2"])
    if id:
        return accounts.load(id)
    return accounts.add(config["wallets"]["from_key"])


def deploy_mocks(decimals=DECIMALS, initial_value=INITIAL_VALUE):
    """
    Use this script if you want to deploy mocks to a testnet
    """
    print(f"The active network is {network.show_active()}")
    print("Deploying Mocks...")
    account = get_account()
    print("Deploying Mock Link Token...")
