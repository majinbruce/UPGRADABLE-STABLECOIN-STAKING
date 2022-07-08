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
    struct stablecoinHolder {
        address stablecoinId;
        uint256 stakingStartTimeStamp;
        uint256 holderId;
    }

    struct stablecoin {
        uint256 stablecoinId;
        address stablecoinAddress;
        uint256 listPointer;
    }

    //mappings
    mapping(uint256 => stablecoin) public ListOfStableCoins;
    mapping(address => mapping(uint256 => stablecoinHolder))
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

    function addNewStableCoin(address _stablecoinAddress, uint256 _stablecoinId)
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

    function stakeCoin(uint8 _stablecoinID, uint256 _amount) external {
        address stablecoinAddress = ListOfStableCoins[_stablecoinID]
            .stablecoinAddress;

        address msgSender = msg.sender;
        require(
            IERC20Upgradeable(stablecoinAddress).balanceOf(msgSender) > _amount
        );
        // require stablecoin exists
        stablecoinHolder storage stablecoinholder;
        stablecoinholder = ListOfStableCoinHolders[msgSender][_stablecoinId];

        
    }

    function unStakeCoin(address _stablecoin, uint256 _amount) external {}

    function getPerks() internal {}

    function calculateReward() internal {}
}
