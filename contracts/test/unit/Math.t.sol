pragma solidity ^0.8.0;

import {MathUtils} from "./../../src/libraries/MathUtils.sol";
import "forge-std/Test.sol";

contract MathTest is Test {
    function testFuzzRatio(uint128 numerator, uint128 denominator) external pure {
        vm.assume(numerator != 0 && denominator != 0 && numerator / denominator == 2);

        uint256 result = MathUtils.calculateRatio(uint256(numerator), uint256(denominator));

        assertApproxEqAbs(result, 2e18, 1e18);
    }
}
