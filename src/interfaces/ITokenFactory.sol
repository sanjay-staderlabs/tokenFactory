// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

    struct TokenData{
        address proxyAdmin;
        address owner;
    }

interface ITokenFactory {

    error ZeroAddress();
    error InvalidOwner();
    event TokenDeployed(address deployer, address tokenAddress);
    event UpgradedTokenImplementation(address indexed token, address implementation);
}