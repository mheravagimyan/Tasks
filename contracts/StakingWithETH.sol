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
    address owner;
    YVNToken public token;
    uint public time;
    uint public x; // amount/second
    uint totalEth;
    address[] user;

    struct User {
        uint ethBalance;
        uint reward;
    }

    mapping(address => User) public users;

    event Deposit(address indexed sender, uint amount);
    event Withdraw(address indexed sender, uint EthAmount, uint rewardAmount);
    event Claim(address indexed sender, uint rewardAmount);

    modifier onlyOwner() {
        require(owner == msg.sender, "StakingWithETH: Not an owner!");
        _;
    }

    modifier access(address _addr) {
        require(owner == msg.sender || _addr == msg.sender, "StakingWithETH: Must be owner or get only own data!");
        _;
    } 

    /**
     * @dev get initial amount to add persecond
     * @param _yvnAddress YVN Token address
     * @param _x amount to add persecond
     */
    constructor(address _yvnAddress, uint _x) {
        owner = msg.sender;
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

        emit Deposit(msg.sender, msg.value);
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

        emit Withdraw(msg.sender, userData.ethBalance, userData.reward);
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

        emit Claim(msg.sender, claimAmount);
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
     * @param _addr target address
     */
    function deleteUser(address _addr) private {
        for (uint i; i < user.length; i++) {
            if (user[i] == _addr) {
                user[i] = user[user.length - 1];
                user.pop();
            }
        }
    }

    /**
     * @dev to get users data
     * @dev Each user can take only own data or sender must be owner
     * @param _addr user address
     * @return data of user
     */
    function getUserData(address _addr) public view access(_addr) returns(User memory) {
        return users[_addr];
    }

    /**
     * @dev to get current token amount before sharing
     * @return amount of tokens that accumulated;
     */
    function getCurrentReward() public view onlyOwner returns(uint) {
        return (block.timestamp - time) * x;
    }

}
