// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IFanLink {
    function balanceOfExternalID(address account, string memory externalId)
        external
        view
        returns (uint256);

    function isFanLinkOwner(address account) external view returns (bool);

    function ownerCount() external view returns (uint256);

    function fansOf(string memory externalId)
        external
        view
        returns (address[] memory);

    function FanLinkFanOf(address account)
        external
        view
        returns (string[] memory);

    function mint(
        address account,
        string memory externalId,
        uint256 amount
    ) external;

    function mintBatch(string[] memory ids) external;
}
