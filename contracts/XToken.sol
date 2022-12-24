// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract XToken is ERC20("XToken", "X") {

    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "XToken: Not an owner!");
        _;
    }

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    } 

    function burn(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    } 
}