// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/**
 * @title Game
 * @dev this contract send money to players if they guess the number with difference -5 or +5
 *otherwise they will lose and lose their bet
 */
contract Game {
    address owner;

    event Win(address indexed winner, uint value);
    event Lose(address indexed Loser);

    modifier onlyOwner() {
        require(msg.sender == owner, "Game: Not an owner!");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev to get random number via keccak256
     * @param _number just to generate
     */
    function random(uint _number) public view returns (uint) {
        return
            uint(keccak256(abi.encodePacked(block.timestamp + _number))) % 100;
    }

    /**
     * @dev this function receive Eth and send back twice as much
     * if the user guess number with difference -5 or +5
     * otherwise they will lose and lose their bet
     * @param _number to use during generation
     */
    function play(uint _number) external payable returns (string memory) {
        int rand = int(random(_number));
        int result = int(_number) - rand;
        // Check if user win
        if (result > -5 && result < 5) {
            require(
                address(this).balance >= 2 * msg.value,
                "Please try again, somthing went wrong!"
            );
            payable(msg.sender).transfer(2 * msg.value);

            emit Win(msg.sender, 2 * msg.value);
            return "You Win, Congratulations!";
        } else {
            emit Lose(msg.sender);
            return "You Lose try again!";
        }
    }

    /**
     * @dev to withdraw funds for owner
     * @param _amount to understand the withdrawal amount
     */
    function withdraw(uint _amount) external payable onlyOwner {
        require(address(this).balance > _amount, "Not enough funds!");
        payable(owner).transfer(address(this).balance);
    }
}
