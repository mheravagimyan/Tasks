// SPDX-License-Identifier: MIT
// pragma solidity 0.8.9;

// /**
//  * @title Integral
//  * @dev this contract calculate a definite integral using the rectangular integration.
//  * the number of iterations is 100.
//  */
// contract Integral {
//     uint index;
//     struct Data {
//         uint coefficient;
//         uint degree;
//     }

//     /**
//      * @dev get parameter and return the functions value (for simplicity, the given function will be only polynomial)
//      * @param x each iteration result
//      * @return value of function at the given point
//      */
//     function inFunction(uint x) public pure returns (uint) {
//         return x ** 2;
//     }

//     /**
//      * @dev calculate a definite integral
//      * @param a the lower bound
//      * @param b the upper bound
//      * @param n iteration amount
//      * @return value of definite integral
//      */
//     function calcIntegral(uint a, uint b, uint n) public pure returns (uint) {
//         uint result;
//         uint h = ((b - a) * 1000) / n; // * 1000 to store numbers after the decimal point

//         for (uint i; i < n; i++) {
//             result += inFunction(a * 1000 + h / 2 + i * h); // * 1000 to store numbers after the decimal point
//         }

//         result *= h;
//         result /= 1000000000; // to get the correct value
//         return result;
//     }
// }

pragma solidity 0.8.9;

contract Integral {

    function calc(uint[][] memory arr, uint x) public pure returns (uint) {
        uint result;
        for(uint i; i < arr.length; i++) {
            result += (arr[i][0] * x ** arr[i][1]) / (1000 ** arr[i][1]);
        }
        return result;
    }


    function calcIntegral(uint[][] memory arr, uint a, uint b, uint n) public pure returns(uint) {
        uint result;
        uint h = (b - a) * 1000 / n;

        for(uint i; i < n; i++) {
            result += calc(arr, a * 1000 + h / 2 + i * h);
        }

        result *= h;
        result /= 1000;
        return result;
    } 

}