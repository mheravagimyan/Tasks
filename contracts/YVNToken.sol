// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title YVNToken
 * @dev ERC20 token inherited from IERC20 interface and Ownable
 */
contract YVNToken is IERC20, Ownable {
    uint _totalSupply;
    uint _maxSupply;
    uint _decimals = 18;
    string _name;
    string _symbol;

    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowances;

    constructor(
        string memory name_,
        string memory symbol_,
        uint maxSupply_
    ) {
        _name = name_;
        _symbol = symbol_;
        _maxSupply = maxSupply_;
    }

    /**
     * @dev to get token name
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev to get token Symbol
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev to get token decimals
     */
    function decimals() external view returns (uint) {
        return _decimals;
    }

    /**
     * @dev to get token maxSupply
     */
    function maxSupply() external view returns (uint) {
        return _maxSupply;
    }

    /**
     * @dev to get token current total supply
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev to get the balance of account
     * @param _account target address
     */
    function balanceOf(address _account) external view returns (uint256) {
        return balances[_account];
    }

    /**
     * @dev to transfer tokens from one account to another
     * @param _to the address to which the tokens are transferred
     * @param _amount shipping amount
     */
    function transfer(address _to, uint256 _amount) external returns (bool) {
        require(_to != address(0), "Cant transfer to 0 address!");
        require(balances[msg.sender] >= _amount, "Not enough tokens!");
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;

        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    /**
     * @dev to check allowance from one account to another
     * @param _owner the address of account that gives allowance
     * @param _spender the address of account that get allowance
     * @return amount of allowance
     */
    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint256) {
        require(
            _owner != address(0) && _spender != address(0),
            "Incorrect addresses!"
        );
        return allowances[_owner][_spender];
    }

    /**
     * @dev to give allowance from initiator of transaction to another account
     * @param _spender the address of account that get allowance
     * @param _amount the amount of allowance
     */
    function approve(
        address _spender,
        uint256 _amount
    ) external returns (bool) {
        require(_spender != address(0), "Cant approve to 0 address!");
        require(balances[msg.sender] >= _amount, "Not enough tokens!");
        allowances[msg.sender][_spender] += _amount;

        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    /**
     * @dev transfer token from one account to another via checking allowance
     * @param _from the address of sender
     * @param _to the address of receiver
     * @param _amount shipping amount
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool) {
        require(
            _from != address(0) && _to != address(0),
            "Incorrect addresses!"
        );
        require(balances[_from] >= _amount, "Not enough tokens!");
        require(allowance(_from, msg.sender) >= _amount, "Incorrect amount!");
        balances[_from] -= _amount;
        allowances[_from][msg.sender] -= _amount;
        balances[_to] += _amount;

        emit Transfer(_from, _to, _amount);
        return true;
    }

    /**
     * @dev to burn tokens amount from target address
     * @param _addr target address
     * @param _amount tokens amount ot burn
     */
    function burn(address _addr, uint _amount) public onlyOwner {
        require(_addr != address(0), "Incorrect address!");
        require(balances[_addr] >= _amount, "Incorrect amount!");
        balances[_addr] -= _amount;
        _totalSupply -= _amount;
    }

    /**
     * @dev to mint tokens to target address
     * @param _addr target address
     * @param _amount tokens amount to mint
     */
    function mint(address _addr, uint _amount) public onlyOwner {
        require(_addr != address(0), "Incorrect address!");
        require(_totalSupply + _amount <= _maxSupply, "Cant mint token!");
        balances[_addr] += _amount;
        _totalSupply += _amount;
    }
}
