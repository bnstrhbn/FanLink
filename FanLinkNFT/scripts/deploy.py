# deploying parent NFT and some children to test with
from scripts.helpful_scripts import (
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
    get_account,
    network,
    config,
)
from brownie import FanLink


def deploy():
    account = get_account()
    # We want to be able to use the deployed contracts if we are on a testnet
    # Otherwise, we want to deploy some mocks and use those
    # Rinkeby
    fanlink = FanLink.deploy(
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify", False),
    )
    print("New FanLink has been created!")

    ids1 = [
        "74gcBzlQza1bSfob90yRhR",  # city and colour
        "6SSXfZGnJaNajWRPGHq4JL",  # red city radio
        "27M9shmwhIjRo7WntpT9Rp",  # frank turner
        "7HWFXU9pHBj0u58yoRwwOJ",  # Menzingers
    ]
    mintTx1 = fanlink.mintBatch(ids1, {"from": account})
    mintTx1.wait(1)
    print("First tx done!")
    balance1 = fanlink.balanceOfExternalID(
        account, "74gcBzlQza1bSfob90yRhR"
    )  # city and color
    balance2 = fanlink.balanceOfExternalID(
        account, "27M9shmwhIjRo7WntpT9Rp"
    )  # frank turner
    balance3 = fanlink.balanceOfExternalID(
        account, "7If8DXZN7mlGdQkLE2FaMo"
    )  # gaslight
    print(f"balance of {account} - City and Colour - {balance1} - should be 1")
    print(f"balance of {account} - Frank Turner - {balance2} - should be 1")
    print(f"balance of {account} - Gaslight Anthem - {balance3} - should be 0")
    # round 2 batchmint - mixing it up a bit.
    ids2 = [
        "6bx5jeXP6LSRVY29adUFdB",  # flatliners
        "7If8DXZN7mlGdQkLE2FaMo",  # gaslight
        "27M9shmwhIjRo7WntpT9Rp",  # frank
        "7HWFXU9pHBj0u58yoRwwOJ",  # menzingers
        "74gcBzlQza1bSfob90yRhR",  # city and colour - note if you add the same artist twice it gets counted twice and increments just fine.
    ]
    mintTx2 = fanlink.mintBatch(ids2, {"from": account})
    mintTx2.wait(1)
    print("Second tx done!")
    balance4 = fanlink.balanceOfExternalID(
        account, "74gcBzlQza1bSfob90yRhR"
    )  # city and color
    balance5 = fanlink.balanceOfExternalID(
        account, "27M9shmwhIjRo7WntpT9Rp"
    )  # frank turner
    balance6 = fanlink.balanceOfExternalID(
        account, "7If8DXZN7mlGdQkLE2FaMo"
    )  # gaslight
    print(f"balance of {account} - City and Colour - {balance4} - should be 2")
    print(f"balance of {account} - Frank Turner - {balance5} - should be 2")
    print(f"balance of {account} - Gaslight - {balance6} - should be 1")

    mintTx3 = fanlink.mintBatch(ids2, {"from": account})
    mintTx3.wait(1)
    print("Third tx done!")
    balance7 = fanlink.balanceOfExternalID(
        account, "74gcBzlQza1bSfob90yRhR"
    )  # city and color
    balance8 = fanlink.balanceOfExternalID(
        account, "27M9shmwhIjRo7WntpT9Rp"
    )  # frank turner
    balance9 = fanlink.balanceOfExternalID(
        account, "7If8DXZN7mlGdQkLE2FaMo"
    )  # gaslight
    print(f"balance of {account} - City and Colour - {balance7} - should be 3")
    print(f"balance of {account} - Frank Turner - {balance8} - should be 3")
    print(f"balance of {account} - Gaslight - {balance9} - should be 2")

    fan1 = fanlink.fansOf("74gcBzlQza1bSfob90yRhR")
    fan2 = fanlink.fansOf("27M9shmwhIjRo7WntpT9Rp2221212")
    print(f"Fans of City and Colour: {fan1} ///Fans of nonsense artist - {fan2}")

    fanlist1 = fanlink.FanLinkFanOf(account)
    totalArtist = fanlink.artistCount()
    print(f"Account {account} is fan of the following: {fanlist1}")
    print(f"total artists: {totalArtist}")
    return fanlink


def main():
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
    ):  # for testing wtih multiple accounts - Kovan not yet supported by .env
        accSwitch = 1
    else:
        accSwitch = None
    fanlink = deploy()
