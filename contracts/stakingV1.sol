// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.8;

/// @title upgradable-stablecoin-staking-contract
/// @author OMKAR N CHOUDHARI
/// @notice You can use this contract for only the most basic simulation
/// @dev All function calls are currently implemented without side effects
/// @custom:experimental This is an experimental contract.

import "./chainlinkAggregator.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "hardhat/console.sol";

contract staking is OwnableUpgradeable, UUPSUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    IERC20Upgradeable private token;
    chainlinkAggregator aggregator;

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
        address priceFeed;
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

    function addNewStableCoin(
        address _stablecoinAddress,
        address _priceFeed,
        uint8 _stablecoinId
    ) external onlyOwner {
        require(
            !stablecoinExists(_stablecoinAddress, _stablecoinId),
            "addNewStableCoin: stablecoin with this Id or address already exists"
        );

        ListOfStableCoins[_stablecoinId].stablecoinAddress = _stablecoinAddress;
        ListOfStableCoins[_stablecoinId].stablecoinId = _stablecoinId;
        ListOfStableCoins[_stablecoinId].priceFeed = _priceFeed;
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

    function initialize(
        IERC20Upgradeable _token,
        address _chainlinkAggregatorAddress
    ) external initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        token = _token;
        aggregator = chainlinkAggregator(_chainlinkAggregatorAddress);
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
            stablecoinholder.amount >= _amount,
            "UnstakeCoin: you do not have enough staked tokens"
        );
        // require stablecoin exists

        uint256 timeElapsed = calculateTimeElapsed(
            stablecoinholder.stakingStartTimeStamp
        );
        address priceFeed = ListOfStableCoins[_stablecoinId].priceFeed;

        uint256 reward = getReward(_amount, timeElapsed, priceFeed);

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
        view
        returns (uint256 timeElapsed)
    {
        return block.timestamp - stakingStartTimeStamp;
    }

    function getPerks(address priceFeed, uint256 _amount)
        internal
        view
        returns (uint256)
    {
        
        uint256 priceOfStablecoin = uint256(
            aggregator.getLatestPrice(priceFeed)
        );
        uint256 usdValueOfStablecoins = priceOfStablecoin * _amount;
        if (usdValueOfStablecoins < 100) return 0;
        else if (usdValueOfStablecoins < 500) return 2;
        else if (usdValueOfStablecoins < 1000) return 5;
        else return 10;
    }

    function getinterestRateAndPerks(
        uint256 timeElapsed,
        address priceFeed,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 perks = getPerks(priceFeed, amount);
        if (timeElapsed < 31 days) {
            return 5 + perks;
        } else if (timeElapsed < 183 days) {
            return 10 + perks;
        } else if (timeElapsed < 365 days) {
            return 15 + perks;
        } else return 18 + perks;
    }

    function getReward(
        uint256 amount,
        uint256 timeElapsed,
        address priceFeed
    ) internal view returns (uint256) {
        uint256 interestAndPerk = getinterestRateAndPerks(
            timeElapsed,
            priceFeed,
            amount
        );
        uint256 denominator = 365 days * 100;
        uint256 reward = (interestAndPerk * amount * timeElapsed) / denominator;
        return reward;
    }
}
