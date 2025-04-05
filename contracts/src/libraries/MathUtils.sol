pragma solidity ^0.8.0;

library MathUtils {
    function calculateRatio(uint256 a, uint256 b) internal pure returns (uint256 ratio) {
        ratio = (a * 1e18) / b;
    }
}
