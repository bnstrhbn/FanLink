// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IFanLink.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ArtistTools is VRFConsumerBase {
    address private constant FanLinkAddress =
        0xd7158dE65f5428B47541F2957c3ed762a0d36313;
    //Price Feed stuff
    address private constant priceFeedAddress =
        0x9326BFA02ADD2366b30bacB125260Af641031331; //currently set to ETHUSD on Kovan
    AggregatorV3Interface internal priceFeed;

    //VRF stuff https://docs.chain.link/docs/vrf-contracts/v1/
    address private constant vrfCoordinatorAddress =
        0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9;
    address private constant LINKTokenAddress =
        0xa36085F69e2889c224210F603D836748e7dC0088;
    bytes32 internal keyHash =
        0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
    uint256 internal fee = 0.1 * 10**18; // 0.1 LINK

    event ReturnedRandomnessRaw(uint256 randomNumber);
    event ReturnedRandomFan(uint256 randomFan);

    //vrf mapping requestID => ticketvalue in wei
    mapping(bytes32 => artistLottery) ticketLotteryMap;
    struct artistLottery {
        uint256 value;
        string artistExternalID;
    }

    constructor() VRFConsumerBase(vrfCoordinatorAddress, LINKTokenAddress) {
        //pricefeed stuff
        priceFeed = AggregatorV3Interface(priceFeedAddress);
        //FanLink stuff
        //fanLink = IFanLink(FanLinkAddress);
    }

    function buyTicketsForFansOfArtist(
        string memory artistExternalID,
        uint256 ticketPriceUSD
    ) public payable {
        address[] memory fanAry = IFanLink(FanLinkAddress).fansOf(
            artistExternalID
        );
        uint256 amountPerTicket = (ticketPriceUSD * 10**18) /
            (getLatestPrice()); //convert USD to Eth amount based on pricefeed.
        require(
            (msg.value) >= (amountPerTicket * fanAry.length),
            "Not enough Eth sent in transaction to cover the tickets!"
        );
        // transfer the required amount of ether to each one of the fans
        for (uint256 i = 0; i < fanAry.length; i++) {
            payable(fanAry[i]).transfer(amountPerTicket * 10**8); //convert to wei
        }
    }

    function buyTicketsForRandomFanOfArtist(
        string memory artistExternalID,
        uint256 ticketPriceUSD
    ) public payable {
        uint256 amountPerTicket = (ticketPriceUSD * 10**18) /
            (getLatestPrice()); //convert USD to Eth amount based on pricefeed.
        require(
            (msg.value) >= (amountPerTicket),
            "Not enough Eth sent in transaction to cover the ticket!"
        );
        // store the required amount of ether to pay one of the fans in the VRFConsumer function
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );
        bytes32 requestId = requestRandomness(keyHash, fee);
        ticketLotteryMap[requestId] = artistLottery(
            msg.value,
            artistExternalID
        );
    }

    function checkTicketPricesInWei(uint256 ticketPriceUSD, uint256 ticketCount)
        public
        view
        returns (uint256)
    {
        uint256 amountPerTicket = (ticketPriceUSD * 10**18) /
            (getLatestPrice()); //convert USD to Eth amount based on pricefeed.
        return amountPerTicket * ticketCount * 10**8; //returns in wei
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() internal view returns (uint256) {
        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    /**
     * Callback function used by VRF Coordinator
     */

    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        emit ReturnedRandomnessRaw(randomness);
        address[] memory fanAry = IFanLink(FanLinkAddress).fansOf(
            ticketLotteryMap[requestId].artistExternalID
        );
        uint256 randomResult = (randomness % fanAry.length);
        emit ReturnedRandomFan(randomResult);
        payable(fanAry[randomResult]).transfer(
            ticketLotteryMap[requestId].value
        );
    }
}
