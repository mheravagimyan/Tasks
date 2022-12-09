// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title YVNToken
 * @dev ERC20 token inherited from IERC20 interface and Ownable
 */
contract YVNToken is IERC20, Ownable {
    address owner;
    uint _totalSupply;
    uint maxTotalSupply;
    uint decimals = 18;
    string name;
    string symbol;

    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowances;

    constructor(
        string memory _name,
        string memory _symbol,
        uint _maxTotalSupply
    ) {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        maxTotalSupply = _maxTotalSupply;
        _totalSupply = _maxTotalSupply;
    }

    /**
     * @dev to get token name
     */
    function getName() external view returns (string memory) {
        return name;
    }

    /**
     * @dev to get token Symbol
     */
    function getSymbol() external view returns (string memory) {
        return symbol;
    }

    /**
     * @dev to get token decimals
     */
    function getDecimals() external view returns (uint) {
        return decimals;
    }

    /**
     * @dev to get token total supply
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
        require(_to != address(0), "Cant approve to 0 address!");
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
        require(allowance(_from, _to) >= _amount, "Incorrect amount!");
        balances[_from] -= _amount;
        allowances[_from][_to] -= _amount;
        balances[_to] += _amount;

        emit Transfer(_from, _to, _amount);
    }

    /**
     * @dev to burn tokens amount from target address
     * @param _addr target address
     * @param _amount tokens amount ot burn
     */
    function burn(address _addr, uint _amount) public onlyOwner {
        require(balances[_addr] >= _amount, "Incorrect amount!");
        require(_totalSupply >= _amount, "Incorrect amount!");
        _totalSupply -= _amount;
    }

    /**
     * @dev to mint tokens to target address
     * @param _addr target address
     * @param _amount tokens amount to mint
     */
    function mint(address _addr, uint _amount) public onlyOwner {
        require(_totalSupply + _amount <= maxTotalSupply, "Cant mint token!");
        balances[_addr] += _amount;
        _totalSupply += _amount;
    }
}
