// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.8;

/// @title upgradable-stablecoin-staking-contract
/// @author OMKAR N CHOUDHARI
/// @notice You can use this contract for only the most basic simulation
/// @dev All function calls are currently implemented without side effects
/// @custom:experimental This is an experimental contract.

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "hardhat/console.sol";

contract staking is OwnableUpgradeable, UUPSUpgradeable {
    //  address public constant DAIPerUSD =
    //    0x2bA49Aaa16E6afD2a993473cfB70Fa8559B523cF;
    //  address public constant USDCPerUSD =
    //     0xa24de01df22b63d23Ebc1882a5E3d4ec0d907bFB;

    using SafeERC20Upgradeable for IERC20Upgradeable;
    IERC20Upgradeable private token;

    address[] public listOfSupportedStableCoinAddress;

    // events

    //struct
    struct StablecoinHolder {
        uint8 stablecoinId;
        uint256 stakingStartTimeStamp;
        uint256 amount;
        bool isStaked;
    }

    struct Stablecoin {
        address stablecoinAddress;
        uint8 stablecoinId;
        uint256 listPointer;
    }

    //mappings
    mapping(uint256 => Stablecoin) public ListOfStableCoins;
    mapping(address => mapping(uint256 => StablecoinHolder))
        public ListOfStableCoinHolders;

    uint256[] private stablecoinIds;

    function stablecoinExists(address _stablecoinAddress, uint256 _stablecoinId)
        internal
        view
        returns (bool success)
    {
        return (ListOfStableCoins[_stablecoinId].stablecoinId ==
            _stablecoinId &&
            ListOfStableCoins[_stablecoinId].stablecoinAddress ==
            _stablecoinAddress);
    }

    function addNewStableCoin(address _stablecoinAddress, uint8 _stablecoinId)
        external
        onlyOwner
    {
        require(
            !stablecoinExists(_stablecoinAddress, _stablecoinId),
            "addNewStableCoin: stablecoin with this Id or address already exists"
        );

        ListOfStableCoins[_stablecoinId].stablecoinAddress = _stablecoinAddress;
        ListOfStableCoins[_stablecoinId].stablecoinId = _stablecoinId;
        stablecoinIds.push(_stablecoinId);
        ListOfStableCoins[_stablecoinId].listPointer = stablecoinIds.length - 1;
    }

    function removeStablecoin(address _stablecoinAddress, uint256 _stablecoinId)
        external
        onlyOwner
    {
        require(
            stablecoinExists(_stablecoinAddress, _stablecoinId),
            "addNewStableCoin: stablecoin with this Id does not exist"
        );

        uint256 keyToDelete = ListOfStableCoins[_stablecoinId].listPointer;
        uint256 keyToMove = stablecoinIds[stablecoinIds.length - 1];
        stablecoinIds[keyToDelete] = keyToMove;
        ListOfStableCoins[keyToMove].listPointer = keyToDelete;
        stablecoinIds.pop();
        delete ListOfStableCoins[_stablecoinId];
    }

    function initialize(IERC20Upgradeable _token) external initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        token = _token;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        view
        override
        onlyOwner
    {}

    function stakeCoin(uint8 _stablecoinId, uint256 _amount) external {
        address stablecoinAddress = ListOfStableCoins[_stablecoinId]
            .stablecoinAddress;

    
        address msgSender = msg.sender;
        StablecoinHolder storage stablecoinholder = ListOfStableCoinHolders[
            msgSender
        ][_stablecoinId];

        require(
            stablecoinholder.isStaked == false,
            "stakeCoin: you have already staked your tokens, unstake your tokens to stake new tokens"
        );
        require(
            IERC20Upgradeable(stablecoinAddress).balanceOf(msgSender) > _amount
        );
        // require stablecoin exists

        ListOfStableCoinHolders[msgSender][_stablecoinId] = StablecoinHolder(
            _stablecoinId,
            block.timestamp,
            _amount,
            true
        );

        IERC20Upgradeable(stablecoinAddress).safeTransferFrom(
            msgSender,
            address(this),
            _amount
        );
    }

    function unStakeCoin(uint8 _stablecoinId, uint256 _amount) external {
        address stablecoinAddress = ListOfStableCoins[_stablecoinId]
            .stablecoinAddress;
        address msgSender = msg.sender;
        StablecoinHolder storage stablecoinholder = ListOfStableCoinHolders[
            msgSender
        ][_stablecoinId];

        require(
            stablecoinholder.isStaked == true,
            "UnstakeCoin: you have not staked your tokens"
        );
        require(
            stablecoinholder.amount > _amount,
            "UnstakeCoin: you do not have enough staked tokens"
        );
        // require stablecoin exists

        uint256 timeElapsed = calculateTimeElapsed(
            stablecoinholder.stakingStartTimeStamp
        );

        uint256 reward = calculateReward(timeElapsed, _amount);

        // transfer the staked stablecoin
        IERC20Upgradeable(stablecoinAddress).safeTransferFrom(
            address(this),
            msgSender,
            _amount
        );

        // transfer reward accumulated
        token.safeTransfer(msgSender, reward);
    }

    function calculateTimeElapsed(uint256 stakingStartTimeStamp)
        internal
        returns (uint256 timeElapsed)
    {
        return block.timestamp - stakingStartTimeStamp;
    }

    function getPerks() internal {
        
    }

    function calculateReward(uint256 timeElapsed, uint256 amount)
        internal
        returns (uint256 reward)
    {}
}
