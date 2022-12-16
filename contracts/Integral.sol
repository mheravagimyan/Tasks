//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title Integral
 * @dev this contract calculate a definite integral using the rectangular integration.
 * the number of iterations is 100.
 */
contract Integral {
    // to count the sum after the decimal point
    uint public sum;
    // to save the result as string
    string public answer;

    /**
     * @dev get parameter and return the functions value (for simplicity, the given function will be only polynomial)
     * @param x each iteration result
     * @param arr the array which will be made up of pairs of numbers
     * the first is coefficient and the second is degree
     * @return value of function at the given point
     */
    function calc(uint[][] memory arr, uint x) private returns (uint) {
        uint result;
        uint item;
        for(uint i; i < arr.length; i++) {
            item = arr[i][0] * x ** arr[i][1]; 
            sum += (item / (10000 ** (arr[i][1] - 1))) % 10000; // receive the sum after the decimal point 
            result += item / (10000 ** arr[i][1]); // receive the sum before the decimal point
        }
        return result;
    }
    
    /**
     * @dev calculate a definite integral
     * @param arr the array which will be made up of pairs of numbers
     * the first is coefficient and the second is degree
     * @param a the lower bound
     * @param b the upper bound
     * @param n iteration amount
     */
    function calcIntegral(uint[][] memory arr, uint a, uint b, uint n) public {
        uint result;
        uint h = (b - a) * 10000 / n;

        for(uint i; i < n; i++) {
            result += calc(arr, a * 10000 + h / 2 + i * h);
        }
        result += sum / 10000;
        result *= h;
        answer = string(abi.encodePacked(Strings.toString(result / 10000), ".", Strings.toString(result % 1000)));
    }

}
