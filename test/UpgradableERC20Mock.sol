// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControlUpgradeable} from 'openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol';
import {ERC20Upgradeable} from "openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";

contract UpgradableERC20Mock is ERC20Upgradeable,AccessControlUpgradeable {

    constructor(){
        _disableInitializers();
    }
    
    function initialize(string calldata name, string calldata symbol,address admin, uint256 initialSupply) public initializer {
        __ERC20_init(name, symbol);
        __AccessControl_init();
        _mint(admin, initialSupply);
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    function mint(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE){
        _mint(msg.sender, amount);
    }
}