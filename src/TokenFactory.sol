// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import './UpgradableERC20.sol';
import './interfaces/ITokenFactory.sol';

import {AccessControlUpgradeable} from  'openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol';
import {ERC20Upgradeable} from "openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import {TransparentUpgradeableProxy,ITransparentUpgradeableProxy} from 'openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol';
import {ProxyAdmin} from 'openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol';


contract TokenFactory is ITokenFactory, AccessControlUpgradeable{

    UpgradableERC20 public upgradableERC20Impl; 

    ProxyAdmin public proxyAdmin;

    mapping(address => address) public tokenOwnerByAddress; 

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(){
        _disableInitializers();
    }

    function initialize() external initializer {
        __AccessControl_init();
        upgradableERC20Impl = new UpgradableERC20();
        proxyAdmin = new ProxyAdmin();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @dev deploys a token using transparent proxy
     * owner of the proxy is the TokenFactory contract 
     * @param name token name
     * @param symbol token symbol
     * @param initialSupply initial supply of the token to mint and transfer to the caller of this function
     */
    function deployToken(string calldata name, string calldata symbol, uint256 initialSupply) external returns (address){
        TransparentUpgradeableProxy tokenProxy = new TransparentUpgradeableProxy(
            address(upgradableERC20Impl),
            address(proxyAdmin),
            ''
        );
        UpgradableERC20(address(tokenProxy)).initialize(name, symbol,msg.sender, initialSupply);
        tokenOwnerByAddress[address(tokenProxy)] = msg.sender;
        emit TokenDeployed(msg.sender, address(tokenProxy));
        return address(tokenProxy);
    }

    /**
     * @dev only allows owner of the token defined in tokenData to upgrade the implementation
     * @param token address of the token to change implementation
     * @param impl address of the new implementation contract
     */
    function upgradeTokenImplementation(address token, address impl) external{
        if(tokenOwnerByAddress[token] != msg.sender){
            revert InvalidOwner();
        }
        if(impl == address(0)){
            revert ZeroAddress();
        }
        ProxyAdmin(proxyAdmin).upgrade(ITransparentUpgradeableProxy(token),impl);
        emit UpgradedTokenImplementation(token, impl);
    }
}
