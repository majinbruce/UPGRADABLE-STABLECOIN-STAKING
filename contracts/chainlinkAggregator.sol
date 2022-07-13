// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract chainlinkAggregator {
    function getLatestPrice(address priceFeed) public view returns (int256) {
        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = AggregatorV3Interface(priceFeed).latestRoundData();
        uint256 decimalsDenominator = uint256(10**decimals(priceFeed));
        return price / int256(decimalsDenominator);
    }

    function decimals(address priceFeed) internal view returns (uint8) {
        return AggregatorV3Interface(priceFeed).decimals();
    }
}
