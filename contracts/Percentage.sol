// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/**
 * @title Percentage
 * @dev this contract receives funds and send it to partners depending on percentage
 */
contract Percentage {
    uint totalPercentage;
    address owner;
    bool lock;
    

    mapping(address => uint) partners;
    address[] club;

    modifier onlyOwner() {
        require(msg.sender == owner, "Percentage: Not an owner!");
        _;
    }

    modifier noReentrancy{
        require(!lock, "No reentrancy!");
        lock = true;
        _;
        lock = false;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev to add partners with their percentage
     * @param _addr partner address to add
     * @param _percentage to fix partners percentage
     */
    function addPartner(address _addr, uint _percentage) public onlyOwner {
        bool boo;
        uint i;
        (i, boo) = getUserIndex(_addr);
        
        if(!boo) {
            require(totalPercentage + _percentage <= 100, "Percentage: Cant add partner, total percentage become more than 100% !");
            club.push(_addr);
            totalPercentage += _percentage;
        } else {
            require(totalPercentage + _percentage - partners[_addr] <= 100, "Percentage: Cant add partner, total percentage become more than 100% !");
            totalPercentage = totalPercentage + _percentage - partners[_addr];
        }

        partners[_addr] = _percentage;
        
    }

    /**
     * @dev to remove partner from percentage list
     * @param _addr target address to remove from list
     */
    function deletePartner(address _addr) public onlyOwner {
        bool boo;
        uint i;
        (i, boo) = getUserIndex(_addr);
        if(!boo){
            return;
        }

        delete partners[_addr];
        deleteFromClub(i);
    }

    /**
     * @dev to remove partner from club
     */
    function deleteFromClub(uint i) private {
        
        totalPercentage -= partners[club[i]];
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
     * @return bool variable to understand is the address on the club
     */
    function getUserIndex(address _addr) private view returns (uint, bool) {
        uint i;
        bool boo;
        for(i; i < club.length; i++) {
            if(club[i] == _addr) {
                boo = true;
                break;
            }
        }
        return (i, boo);
    }

    /**
     * @dev to receive funds and send users
     */
    receive() external payable noReentrancy {
        for (uint i; i < club.length; i++) {
            uint amount = (msg.value * partners[club[i]]) / 100;
            payable(club[i]).transfer(amount);
        }
        if(address(this).balance != 0) {
            payable(owner).transfer(address(this).balance);
        }
    }

   
}
