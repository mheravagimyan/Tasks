// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./YVNToken.sol";

/**
 * @title Staking With Eth
 * @dev this contract receives users deposit in ETH and add YVN tokens amount in initial amount persecond.
 * Users can receive their funds with two way.
 * 1. Receive their reward
 * 2. Receive their reward and ETH 
 */
contract StakingWithETH {
    YVNToken token;
    uint time;
    uint x; // amount/second
    uint totalEth;
    address[] user;

    struct User {
        uint ethBalance;
        uint reward;
    }

    mapping(address => User) users;

    /**
     * @dev get initial amount to add persecond
     * @param _yvnAddress YVN Token address
     * @param _x amount to add persecond
     */
    constructor(address _yvnAddress, uint _x) {
        token = YVNToken(_yvnAddress);
        x = _x;
    }

    /**
     * @dev users can deposit funds and receive their tokens after some time
     */
    function deposit() external payable {
        require(
            msg.value > 0,
            "StakingWithETH: Not enough funds on your balance!"
        );

        updateReward();

        if(users[msg.sender].ethBalance == 0) {
            user.push(msg.sender);
        }

        users[msg.sender].ethBalance += msg.value;
        totalEth += msg.value;
    }

    /**
     * @dev to receive ETH and YVN tokens reward.
     */
    function withdraw() external payable {
        require(
            users[msg.sender].ethBalance != 0,
            "StakingWithETH: Have no deposit!"
        );

        updateReward();

        User memory userData = users[msg.sender];

        delete users[msg.sender];
        deleteUser(msg.sender);

        payable(msg.sender).transfer(userData.ethBalance);
        token.transfer(msg.sender, userData.reward);

        totalEth -= userData.ethBalance;
    }

    /**
     * @dev to receive YVN tokens reward.
     */
    function claim() external {
        require(
            users[msg.sender].ethBalance != 0,
            "StakingWithETH: Have no deposit!"
        );

        updateReward();

        uint claimAmount = users[msg.sender].reward;
        users[msg.sender].reward = 0;

        token.transfer(msg.sender, claimAmount);
    }

    /**
     * @dev to update users data in deposit, withdraw or claim time
     */
    function updateReward() private {
        uint intervalAmount = (block.timestamp - time) * x;

        for (uint i; i < user.length; i++) {
            uint amount = intervalAmount * users[user[i]].ethBalance / totalEth;
            users[user[i]].reward += amount;
        }

        time = block.timestamp;
    }

    /**
     * @dev delete users data
     */
    function deleteUser(address _addr) private {
        for (uint i; i < user.length; i++) {
            if (user[i] == _addr) {
                user[i] = user[user.length - 1];
                user.pop();
            }
        }
    }

}
