// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/**
 * @title Sort
 * @dev Sort array and return some of the bigest  numbers
 */
contract Sort {
    /**
     * @dev Sort array and return the bigest _number numbers
     * @param _arr target array for sorting
     * @param _number for understanding how many numbers return
     * @return array waht contain the desired result
     */
    function sort(
        uint[] memory _arr,
        uint _number
    ) public pure returns (uint[] memory) {
        //Sort array via bubble sort
        for (uint i; i < _arr.length; i++) {
            for (uint j; j < _arr.length - i - 1; j++) {
                if (_arr[j] > _arr[j + 1]) {
                    uint a = _arr[j];
                    _arr[j] = _arr[j + 1];
                    _arr[j + 1] = a;
                }
            }
        }

        // Pick the biggest _number numbers and put them in a new array
        uint[] memory ar = new uint[](_number);
        if (_number >= _arr.length) {
            return _arr;
        } else {
            uint i = _arr.length - _number;
            uint j;
            for (i; i < _arr.length; i++) {
                ar[j] = _arr[i];
                j++;
            }
            return ar;
        }
    }
}
