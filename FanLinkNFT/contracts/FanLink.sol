// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract FanLink is ERC1155, Ownable, ERC1155Supply {
    //arguably this would work better as more of ERC20 than ERC721 since within each artist, the tokens can be fungible and it doesn't really matter.
    //in current implementation there's not much reason to be NFTs anyway. Could add more metadata if it's cheap on deployed chain.
    string[] internal idMapAry; //"id" needs to be uint256 so i need an ary of artist ID to ERC1155 id to do translations back-and-forth
    uint256 public artistCount; //count of total unique artists for use with mapping
    address[] internal ownershipAry; //This is an array of unique owners since ERC1155 doesn't track this in an easy-to-use way
    mapping(address => uint256) addressLastUpdateMap;
    event FanLinkMinted(address fan, uint256 timestamp);

    constructor() ERC1155("FanLink") {
        //setup here isn't ecessary
        //fully dynamic. token of "id" - with id coming from Spotify Artist ID.
        //"id" guaranteed unique to Spotify - you'd need to do something if you'd want multiple platforms aggregated
        artistCount = 0;
    }

    //adapter for BalanceOf
    function balanceOfExternalID(address account, string memory externalId)
        public
        view
        returns (uint256)
    {
        //ExternalID being the spotify artist ID
        require(
            account != address(0),
            "ERC1155: balance query for the zero address"
        );
        for (uint256 id = 0; id < artistCount; id++) {
            //check ownerships
            if (stringsEquals(idMapAry[id], externalId)) {
                return this.balanceOf(account, id);
            }
        }
        return 0;
    }

    function isFanLinkOwner(address account) public view returns (bool) {
        //is a given account an owner of any FanLink tokens?
        for (uint256 i = 0; i < ownershipAry.length; i++) {
            if (ownershipAry[i] == account) return true;
        }
        return false;
    }

    function ownerCount() public view returns (uint256) {
        //returns count of unique owners
        return ownershipAry.length;
    }

    function fansOf(string memory externalId)
        public
        view
        returns (address[] memory)
    {
        //takes an artist id (externalID) then loops through those tokens to see who owners are.
        //Then returns unique owner addresses
        for (uint256 id = 0; id < artistCount; id++) {
            //check ownerships - need to translate externalID to internal first though.
            if (stringsEquals(idMapAry[id], externalId)) {
                address[] memory ownerAry = new address[](ownershipAry.length); //max size
                uint256 ownerCt = 0;
                //this is stupid, but looping over my tracked overall owners
                for (uint256 i = 0; i < ownershipAry.length; i++) {
                    if (this.balanceOf(ownershipAry[i], id) > 0)
                        ownerAry[ownerCt] = ownershipAry[i];
                    ownerCt++;
                }
                return ownerAry;
            }
        }
    }

    function FanLinkFanOf(address account)
        public
        view
        returns (string[] memory)
    {
        //takes an address then returns which artists they are a fan of -
        //loops through ownership array and checks balances of all IDs.
        require(isFanLinkOwner(account), "Not a FanLink Owner");
        string[] memory fanOfAry = new string[](artistCount); //max size
        uint256 artistCt = 0;

        for (uint256 id = 0; id < artistCount; id++) {
            //loop through artists to find tokens. Add External IDs to return ary
            if (this.balanceOf(account, id) > 0) {
                fanOfAry[artistCt] = idMapAry[id];
                artistCt++;
            }
        }
        return fanOfAry;
    }

    function getLastUpdatedTime(address owner) public view returns (uint256) {
        return addressLastUpdateMap[owner];
    }

    /*
    function mint(
        address account,
        string memory externalId,
        uint256 amount
    ) public onlyOwner {
        //disable - leaving enabled for testing.
        if (!isFanLinkOwner(account)) ownershipAry.push(account); //if not owner, add to owner after minting.
        bool found = false; //flag
        uint256 internalID;
        for (uint256 id = 0; id < artistCount; id++) {
            //see if that artist is in the array - translate externalID to internal first though.
            if (stringsEquals(idMapAry[id], externalId)) {
                internalID = id; //translate external id to internal id
                found = true;
            }
        }
        //new artist to push
        if (!found) {
            idMapAry.push(externalId);
            internalID = artistCount;
            artistCount++;
        }
        _mint(account, internalID, amount, "");
    }
    */
    function mintBatch(string[] memory ids) public {
        uint256[] memory amounts = new uint256[](ids.length);
        uint256[] memory internalIds = new uint256[](ids.length);
        if (!isFanLinkOwner(msg.sender)) {
            ownershipAry.push(msg.sender); //if not owner, add to owner after minting.
        } else {
            uint256 delay = 5 minutes;
            require(
                block.timestamp - delay >= addressLastUpdateMap[msg.sender],
                "It's too soon to update your FanLink!"
            );
        }

        //removed OnlyOwner requirement for dynamic minting. Potentially could add requirement that this is coming from EA logic.
        //totalSupply(id) and exists(id) to look at supplies of tokens. inherited from ERC1155Supply.
        // Seems like I don't need a passed in , uint256[] memory amounts either.
        //Passed in IDs of artists to +1 counts
        //Amounts should be pulled from the values currently owned by owner - _mintBatch actually should just cover this and always increment.
        //amounts[index] = this.balanceOf(msg.sender, ids[index]) + 1; would double+1 amounts. Could use something like this for a weighting algorithm.
        //then increment Amounts and mintBatch.
        for (uint256 index = 0; index < ids.length; index++) {
            //for each entry in passed in Artist array
            bool found = false; //flag
            for (uint256 id = 0; id < artistCount; id++) {
                //see if that artist is in the array - translate externalID to internal first though.
                if (stringsEquals(idMapAry[id], ids[index])) {
                    internalIds[index] = id; //translate external id to internal id
                    amounts[index] = 1;
                    found = true;
                }
            }
            //new artist to push
            if (!found) {
                idMapAry.push(ids[index]);
                internalIds[index] = artistCount;
                amounts[index] = 1;
                artistCount++;
            }
        }
        //rather than leave "to" above, force this to be the sender so they have to mint to themselves. removing data too.
        _mintBatch(msg.sender, internalIds, amounts, "");
        addressLastUpdateMap[msg.sender] = block.timestamp;
        emit FanLinkMinted(msg.sender, block.timestamp);
    }

    function stringsEquals(string memory s1, string memory s2)
        private
        pure
        returns (bool)
    {
        bytes memory b1 = bytes(s1);
        bytes memory b2 = bytes(s2);
        uint256 l1 = b1.length;
        if (l1 != b2.length) return false;
        for (uint256 i = 0; i < l1; i++) {
            if (b1[i] != b2[i]) return false;
        }
        return true;
    }

    // The following functions are overrides required by Solidity.
    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `ids` and `amounts` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    //Override Transfer functions to disable.

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(1 == 0, "ERC1155: transfer disabled");
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(1 == 0, "ERC1155: transfer disabled");
    }
}
