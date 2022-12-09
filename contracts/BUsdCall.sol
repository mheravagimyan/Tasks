// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/**
 * @title IBusd
 * @dev create an interface for call BUSD functions
 */
interface IBusd {
    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function getOwner() external view returns (address);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint);

    function balanceOf(address _addr) external view returns (uint256);
}

/**
 * @title BusdCall
 * @dev this contract makes it possible to call BUSD contract functions via IBusd interface
 */

contract BusdCall {
    address busdAddress = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;

    function subName() external view returns (string memory) {
        return IBusd(busdAddress).name();
    }

    function subTotalSupply() external view returns (uint256) {
        return IBusd(busdAddress).totalSupply();
    }

    function subGetOwner() external view returns (address) {
        return IBusd(busdAddress).getOwner();
    }

    function subSymbol() external view returns (string memory) {
        return IBusd(busdAddress).symbol();
    }

    function subDecimals() external view returns (uint) {
        return IBusd(busdAddress).decimals();
    }

    function subBalanceOf(address _addr) external view returns (uint256) {
        return IBusd(busdAddress).balanceOf(_addr);
    }
}
