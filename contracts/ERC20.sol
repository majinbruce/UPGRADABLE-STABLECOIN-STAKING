// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.8;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract MyTokenUpgradeable is
    Initializable,
    ERC20Upgradeable,
    OwnableUpgradeable
{
    function initialize() external initializer {
        __ERC20_init("BRUCE TOKEN", "BTKN");
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}
}
