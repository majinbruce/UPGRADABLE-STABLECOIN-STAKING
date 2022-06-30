// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

/// @title upgradable-stablecoin-staking-contract
/// @author OMKAR N CHOUDHARI
/// @notice You can use this contract for only the most basic simulation
/// @dev All function calls are currently implemented without side effects
/// @custom:experimental This is an experimental contract.

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract staking {
    address public constant DAIPerUSD =
        0x2bA49Aaa16E6afD2a993473cfB70Fa8559B523cF;
    address public constant USDCPerUSD =
        0xa24de01df22b63d23Ebc1882a5E3d4ec0d907bFB;

    using SafeERC20 for IERC20;
    IERC20 private immutable token;

    // events

    //struct
    struct stablecoinHolder {
        address owner;
        uint256 stakingStartTimeStamp;
    }

    //mappings

    constructor(IERC20 _token) {
        token = _token;
    }

    function stakeCoin(string memory stablecoin, uint256 amount) external {
        
    }
}
