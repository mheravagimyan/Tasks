// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./YVNToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Staking
 * @dev this contract receive funds from useres in YVN Token and gives users X Token
 * depending on the course (X / YVN), then every 5 minutes the owner mints YVN amount.
 * Useres can deposit many time and withdraw their funds all or a part.
 */
contract Staking {
    address public owner;
    YVNToken public yvnToken;
    IERC20 public lpToken;
    uint public fee; // percent that owner get when users withdraw their funds
    uint lpTotalAmount; // Amount of X token that contract shared
    uint mintTime; // Fix the time that owner minted

    struct User {
        uint time;
        uint tokenAmount; // LP token amount
        uint deposits; // Amount of deposits
        uint withdraws; // Amount of withdraws
    }

    mapping(address => User) public users;

    modifier onlyOwner {
        require(msg.sender == owner, "Staking: Not an Owner!");
        _;
    }

    event Deposit(address indexed sender, uint depAmount, uint time);
    event Withdraw(address indexed sender, uint amount, uint time);

    /**
     * @dev create contract with initial args
     * @param _yvnTokenAddress YVN token address
     * @param _xTokenAddress X token address
     */
    constructor(address _yvnTokenAddress, address _xTokenAddress, uint _fee) {
        owner = msg.sender;
        fee = _fee;
        yvnToken = YVNToken(_yvnTokenAddress);
        lpToken = IERC20(_xTokenAddress);
    }

    /**
     * @dev to deposit token and receive LP token.
     * Receive tokens depend on the course (LP token / YVN token).
     * User data is saved.
     * @param _amount the amount of tokens that user wants to deposit.
     */
    function deposit(uint _amount) external {
        require(_amount != 0, "Staking: Incorrect amount!");
        require(yvnToken.balanceOf(msg.sender) >= _amount, "Staking: Not enough funds on your balance!");
        require(yvnToken.allowance(msg.sender, address(this)) >= _amount, "Staking: Not enough allowance!");

        uint yvnContractBalance = yvnToken.balanceOf(address(this));
        uint amount = yvnContractBalance == 0 ? _amount : _amount * lpTotalAmount / yvnContractBalance;

        require(lpToken.balanceOf(address(this)) >= amount, "Staking: Not enough funds on contracat!");
        
        users[msg.sender] = User(
            block.timestamp,
            users[msg.sender].tokenAmount + amount,
            ++users[msg.sender].deposits,
            users[msg.sender].withdraws
        );

        yvnToken.transferFrom(msg.sender, address(this), amount);
        lpToken.transfer(msg.sender, amount);
        lpTotalAmount += amount;

        emit Deposit(msg.sender, _amount, block.timestamp);
    }

    /**
     * @dev to withdraw a part of funds that user earnd
     * The owner gets his profit.
     * @param _amount amount of LP Tokens that user want to change
     */
    function withdraw(uint _amount) external {
        require(lpToken.balanceOf(msg.sender) >= _amount, "Staking: Not enough funds!");
        require(lpToken.allowance(msg.sender, address(this)) >= _amount, "Staking: Not enough allowance!");

        users[msg.sender] = User(
            block.timestamp,
            users[msg.sender].tokenAmount - _amount,
            users[msg.sender].deposits,
            ++users[msg.sender].withdraws
        );

        uint userProfit = yvnToken.balanceOf(address(this)) * _amount / lpTotalAmount;
        uint ownerProfit = userProfit * fee / 100;
        userProfit -= ownerProfit;
        lpToken.transferFrom(msg.sender, address(this), _amount);
        yvnToken.transfer(msg.sender, userProfit);
        yvnToken.transfer(owner, ownerProfit);
        lpTotalAmount -= _amount;

        emit Withdraw(msg.sender, userProfit, block.timestamp);
    }

    /**
     * @dev to get user data
     * @param _userAddress address of user that we want to know
     */
    function getUserData(address _userAddress) external view returns(User memory) {
        return users[_userAddress];
    }

}