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

    event newStaked(
        address indexed owner,
        uint256 stablecoinId,
        uint256 amount
    );

    event unStaked(
        address indexed owner,
        uint256 stablecoinId,
        uint256 amount,
        uint256 reward
    );

    struct StablecoinHolder {
        uint256 stakingStartTimeStamp;
        uint256 amount;
        uint256 stablecoinId;
        bool isStaked;
    }

    struct Stablecoin {
        address stablecoinAddress;
        address priceFeed;
        uint256 listPointer;
        uint256 stablecoinId;
    }

    ///@dev maps from stablecoin ID to properties of the stablecoin stored in struct
    mapping(uint256 => Stablecoin) public ListOfStableCoins;

    ///@dev maps from user address to => stablecoinID => properties of user in struct to, double mapping was used so one user can stake diffrent stablecoins
    mapping(address => mapping(uint256 => StablecoinHolder))
        public ListOfStableCoinHolders;

    ///@dev stablecoinIds stored in array
    uint256[] private stablecoinIds;

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

    /// @notice checks if a stablecoin exists
    /// @dev location of listpointer can change hence ID of stablecoin was used as key & listpointer was stored in struct as well
    /// @param _stablecoinAddress contract address of the stablecoin to add
    /// @param _stablecoinId  id of the stablecoin which can be used to access the stablecoin properties
    /// @return success bool to validate in require statements
    function stablecoinExists(address _stablecoinAddress, uint256 _stablecoinId)
        internal
        view
        returns (bool success)
    {
        if (stablecoinIds.length == 0) return false;
        return (stablecoinIds[ListOfStableCoins[_stablecoinId].listPointer] ==
            _stablecoinId &&
            ListOfStableCoins[_stablecoinId].stablecoinAddress ==
            _stablecoinAddress);
    }

    /// @notice lets only owner add new stablecoin support
    /// @dev location of listpointer can change hence ID of stablecoin was used as key
    /// @param _stablecoinAddress contract address of the stablecoin to add
    /// @param _priceFeed chainlink pricefeed of stablecoin/USD pair
    /// @param _stablecoinId  id of the stablecoin which can be used to access the stablecoin properties
    function addNewStableCoin(
        address _stablecoinAddress,
        address _priceFeed,
        uint256 _stablecoinId
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

    /// @notice lets owner remove stablecoin support
    /// @dev deadline parameter could be hardcoded in contract
    /// @param _stablecoinAddress contract address of the stablecoin to add
    /// @param _stablecoinId  id of the stablecoin which can be used to access the stablecoin properties
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
        ListOfStableCoins[keyToMove].listPointer = uint256(keyToDelete);
        stablecoinIds.pop();
        delete ListOfStableCoins[_stablecoinId];
    }

    /// @dev deadline parameter could be hardcoded in contract
    /// @param _stablecoinId  id of the stablecoin which can be used to access the stablecoin properties
    /// @param _amount the amount of stablecoin user wishes to stake
    function stakeCoin(uint256 _stablecoinId, uint256 _amount) external {
        address stablecoinAddress = ListOfStableCoins[_stablecoinId]
            .stablecoinAddress;

        address msgSender = msg.sender;
        StablecoinHolder storage stablecoinholder = ListOfStableCoinHolders[
            msgSender
        ][_stablecoinId];
        require(
            stablecoinExists(stablecoinAddress, _stablecoinId),
            "addNewStableCoin: stablecoin with this Id does not exist"
        );
        require(
            stablecoinholder.isStaked == false,
            "stakeCoin: you have already staked your tokens, unstake your tokens to stake new tokens"
        );
        require(
            IERC20Upgradeable(stablecoinAddress).balanceOf(msgSender) > _amount
        );

        ListOfStableCoinHolders[msgSender][_stablecoinId] = StablecoinHolder(
            block.timestamp,
            _amount,
            _stablecoinId,
            true
        );

        IERC20Upgradeable(stablecoinAddress).safeTransferFrom(
            msgSender,
            address(this),
            _amount
        );
        emit newStaked(msgSender, _stablecoinId, _amount);
    }

    /// @notice lets users unstake their stablecoins
    /// @dev deadline parameter could be hardcoded in contract
    /// @param _stablecoinId  id of the stablecoin which can be used to access the stablecoin properties
    /// @param _amount the amount of stablecoin user wishes to unstake
    function unStakeCoin(uint256 _stablecoinId, uint256 _amount) external {
        address stablecoinAddress = ListOfStableCoins[_stablecoinId]
            .stablecoinAddress;
        address msgSender = msg.sender;
        StablecoinHolder storage stablecoinholder = ListOfStableCoinHolders[
            msgSender
        ][_stablecoinId];
        require(
            stablecoinExists(stablecoinAddress, _stablecoinId),
            "addNewStableCoin: stablecoin with this Id does not exist"
        );

        require(
            stablecoinholder.isStaked == true,
            "UnstakeCoin: you have not staked your tokens"
        );
        require(
            stablecoinholder.amount >= _amount,
            "UnstakeCoin: you do not have enough staked tokens"
        );

        uint256 timeElapsed = calculateTimeElapsed(
            stablecoinholder.stakingStartTimeStamp
        );
        address priceFeed = ListOfStableCoins[_stablecoinId].priceFeed;

        uint256 reward = getReward(_amount, timeElapsed, priceFeed);

        stablecoinholder.isStaked = false;
        // transfer the staked stablecoin
        IERC20Upgradeable(stablecoinAddress).safeTransferFrom(
            address(this),
            msgSender,
            _amount
        );

        // transfer reward accumulated
        token.safeTransfer(msgSender, reward);
        emit unStaked(msgSender, _stablecoinId, _amount, reward);
    }

    /// @notice lets users unstake their stablecoins
    /// @param stakingStartTimeStamp  id of the stablecoin which can be used to access the stablecoin properties
    /// @return timeElapsed returns the amount of the for which tokens were staked
    function calculateTimeElapsed(uint256 stakingStartTimeStamp)
        internal
        view
        returns (uint256 timeElapsed)
    {
        return block.timestamp - stakingStartTimeStamp;
    }

    /// @notice function calculates the perks in terms of percentage based on USD valo of tokens
    /// @dev chainlink price agregator was used to get USD value of stablecoins
    /// @param priceFeed chainlink pricefeed of stablecoin/USD pair
    /// @param _amount the amount of stablecoin user wishes to unstake
    /// @return "perks" returns the perks in terms of percentage
    function getPerks(address priceFeed, uint256 _amount)
        internal
        view
        returns (uint256)
    {
        uint256 priceOfStablecoin = uint256(
            aggregator.getLatestPrice(priceFeed)
        );
        uint256 decimalsDenominator = uint256(
            10**aggregator.decimals(priceFeed)
        );
        uint256 usdValueOfStablecoins = (priceOfStablecoin * _amount) /
            decimalsDenominator;
        console.log(usdValueOfStablecoins, "usdValueOfStablecoins");
        if (usdValueOfStablecoins < 100) return 0;
        else if (usdValueOfStablecoins < 500) return 2;
        else if (usdValueOfStablecoins < 1000) return 5;
        else return 10;
    }

    /// @notice function calculates the perks in terms of percentage based on USD valo of tokens
    /// @dev days parameter was used , leap year was not taken into consideration
    /// @param timeElapsed amount of time tokens staked
    /// @param priceFeed chainlink pricefeed of stablecoin/USD pair
    /// @param amount the amount of stablecoin user wishes to unstake
    /// @return "perks & interest rate" returns the interest rate + perks in terms of percentage
    function getinterestRateAndPerks(
        uint256 timeElapsed,
        address priceFeed,
        uint256 amount
    ) internal view returns (uint256) {
        uint256 perks = getPerks(priceFeed, amount);
        console.log(perks, "perks");
        if (timeElapsed < 31 days) {
            return 5 + perks;
        } else if (timeElapsed < 183 days) {
            return 10 + perks;
        } else if (timeElapsed < 365 days) {
            return 15 + perks;
        } else return 18 + perks;
    }

    /// @notice function calculates the rewards for user based on interest & perks
    /// @dev days parameter was used , 1 year = 365 days
    /// @param priceFeed chainlink pricefeed of stablecoin/USD pair
    /// @param timeElapsed amount of time tokens staked
    /// @param amount the amount of stablecoin user wishes to unstake
    /// @return "reward" returns the rewards to send for user
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
        console.log(interestAndPerk, "interest plus perks");

        uint256 denominator = 365 days * 100;
        uint256 reward = (interestAndPerk * amount * timeElapsed) / denominator;
        return reward;
    }
}
