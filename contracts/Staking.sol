// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./YVNToken.sol";

contract Staking {
    address owner;
    YVNToken token;
    uint currentSupply;

    constructor(address _tokenAddress) {
        owner = msg.sender;
        token = YVNToken(_tokenAddress);
    } 

}