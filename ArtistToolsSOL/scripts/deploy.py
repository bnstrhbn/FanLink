# deploying parent NFT and some children to test with
from scripts.helpful_scripts import (
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
    get_account,
    network,
    config,
)
from brownie import ArtistTools


def deploy():
    account = get_account()
    # We want to be able to use the deployed contracts if we are on a testnet
    # Otherwise, we want to deploy some mocks and use those
    # Rinkeby
    artistTools = ArtistTools.deploy(
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify", False),
    )
    print("New ArtistTools has been created!")

    return artistTools


def main():
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
    ):  # for testing wtih multiple accounts - Kovan not yet supported by .env
        accSwitch = 1
    else:
        accSwitch = None
    fanlink = deploy()
