// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC20 {
    
    function balanceOf (address _account) external view returns (uint256);

    function transferFrom (address _from, address _to, uint256 _amount)  external returns(bool);

    function transfer (address _to, uint256 _amount) external returns (bool);
}