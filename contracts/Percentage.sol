// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/**
 * @title Percentage
 * @dev this contract receives funds and send it to partners depending on percentage
 */
contract Percentage {
    address owner;
    bool lock;

    mapping(address => uint) partners;
    address[] club;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner!");
        _;
    }

    modifier noReentrancy{
        require(!lock, "No reentrancy!");
        lock = true;
        _;
        lock = false;
    }

    event Withdraw(address indexed account, uint balance);

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev to add partners with their percentage
     * @param _addr partner address to add
     * @param _percentage to fix partners percentage
     */
    function addPartner(address _addr, uint _percentage) public onlyOwner {
        uint i = getUserIndex(_addr);

        if(i == club.length) {
            club.push(_addr);
        }
        
        partners[_addr] = _percentage;
        
    }

    /**
     * @dev to remove partner from percentage list
     * @param _addr target address to remove from list
     */
    function deletePartner(address _addr) public onlyOwner {
        delete partners[_addr];
        deleteFromClub(_addr);
    }

    /**
     * @dev to remove partner from club
     * @param _addr target address
     */
    function deleteFromClub(address _addr) private {
        uint i = getUserIndex(_addr);
        address temp;
        temp = club[i];
        club[i] = club[club.length - 1];
        club[club.length - 1] = temp;
        club.pop();        
    }

    /**
     * @dev get index of address in club
     * @param _addr the target address
     * @return index of address 
     */
    function getUserIndex(address _addr) private view returns (uint) {
        uint i;
        for(i; i < club.length; i++) {
            if(club[i] == _addr) {
                break;
            }
        }
        return i;
    }

    /**
     * @dev to receive funds and send users
     */
    receive() external payable noReentrancy {
        for (uint i; i < club.length; i++) {
            uint amount = (msg.value * partners[club[i]]) / 100;
            payable(club[i]).transfer(amount);
        }
    }

   
}
