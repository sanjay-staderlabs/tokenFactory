// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";

import {TokenFactory} from '../src/TokenFactory.sol';
import {TransparentUpgradeableProxy} from 'openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol';
import {ProxyAdmin} from 'openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol';

contract TokenFactoryScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        TokenFactory tokenFactoryImpl = new TokenFactory();
        ProxyAdmin proxyAdmin = new ProxyAdmin();
        console.log('proxy admin owner is ', proxyAdmin.owner());
        console.log('proxyAdmin is ', address(proxyAdmin));

        TransparentUpgradeableProxy tokenFactoryProxy = new TransparentUpgradeableProxy(
            address(tokenFactoryImpl),
            address(proxyAdmin),
            ''
        );
        TokenFactory(address(tokenFactoryProxy)).initialize();
        console.log('tokenFactoryProxy Deployed at ', address(tokenFactoryProxy));
        address bTestToken = TokenFactory(address(tokenFactoryProxy)).deployToken('bTest', 'bTest', 100 ether);
        address berTestToken = TokenFactory(address(tokenFactoryProxy)).deployToken('berTest', 'berTest', 100 ether);

        console.log('bTest token deployed at ',bTestToken);
        console.log('berTest token deployed at ', berTestToken);
        vm.stopBroadcast();
    }
}
