// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.20;

import '../src/interfaces/ITokenFactory.sol';

import {Test, console} from "forge-std/Test.sol";
import {TokenFactory} from "../src/TokenFactory.sol";
import {UpgradableERC20Mock,ERC20Upgradeable} from './UpgradableERC20Mock.sol';
import {TransparentUpgradeableProxy} from 'openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol';
import {ProxyAdmin} from 'openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol';

contract TokenFactoryTest is Test {
    TokenFactory public tokenFactoryProxy;

    function setUp() public {

        TokenFactory tokenFactoryImpl = new TokenFactory();
        ProxyAdmin proxyAdmin = new ProxyAdmin();

        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(tokenFactoryImpl),
            address(proxyAdmin),
            ''
        );
        tokenFactoryProxy = TokenFactory(address(proxy));
        TokenFactory(address(tokenFactoryProxy)).initialize();
    }

    function test_deployToken(uint16 randomSeed) external {
        vm.assume(randomSeed >0);
        address deployer = vm.addr(randomSeed);
        vm.startPrank(deployer);
        ERC20Upgradeable token = ERC20Upgradeable(tokenFactoryProxy.deployToken('test','test', 100 ether));
        assertEq(ProxyAdmin(tokenFactoryProxy.proxyAdmin()).owner(), address(tokenFactoryProxy));
        assertEq(token.totalSupply(),100 ether);
        assertEq(token.balanceOf(deployer),100 ether);
    }

    function test_upgradeTokenImplementationToIncludeMintFunction(uint16 randomSeed, uint16 amount) external {
        vm.assume(randomSeed >0);
        address deployer = vm.addr(randomSeed);
        vm.startPrank(deployer);
        address token = tokenFactoryProxy.deployToken('test2','test2', amount);
        UpgradableERC20Mock newImpl = new UpgradableERC20Mock();
        assertEq(ERC20Upgradeable(token).totalSupply(),amount);

        tokenFactoryProxy.upgradeTokenImplementation(token, address(newImpl));
        UpgradableERC20Mock(token).mint(10 ether);
        assertEq(ERC20Upgradeable(token).totalSupply(),amount + 10 ether);
        assertEq(ERC20Upgradeable(token).balanceOf(deployer),amount + 10 ether);
    }

    function testFail_upgradeTokenImplementationWithZeroAddress(uint16 randomSeed) external {
        vm.assume(randomSeed >0);
        address deployer = vm.addr(randomSeed);
        vm.startPrank(deployer);
        address token = tokenFactoryProxy.deployToken('test2','test2', 10 ether);
        tokenFactoryProxy.upgradeTokenImplementation(token, address(0));
    }

    function testFail_upgradeTokenImplementationWithInvalidOwner(uint16 randomSeed) external {
        vm.assume(randomSeed >0);
        address deployer = vm.addr(randomSeed);
        vm.assume(deployer != address(this));
        vm.startPrank(deployer);
        address token = tokenFactoryProxy.deployToken('test2','test2', 10 ether);
        UpgradableERC20Mock newImpl = new UpgradableERC20Mock();
        vm.stopPrank();
        tokenFactoryProxy.upgradeTokenImplementation(token, address(newImpl));
    }

}
