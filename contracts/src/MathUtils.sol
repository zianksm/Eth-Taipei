// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

type IntentId is bytes32;

// by default all intents have partial fill
struct Intents {
    address inToken;
    address outToken;
}

struct IntentSpecification {
    uint256 inAmount;
    uint256 outAmount;
}

library MathUtils {
    function calculateRatio(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 ratio)
    {
        ratio = (a * 1e18) / b;
    }
}

library IntentLibrary {
    function toId(Intents memory intent) internal pure returns (IntentId id) {
        id = toId(intent.inToken, intent.outToken);
    }

    function toRatio(IntentSpecification memory intent)
        internal
        pure
        returns (uint256 ratio)
    {
        ratio = MathUtils.calculateRatio(intent.inAmount, intent.outAmount);
    }

    function toId(address _in, address out)
        internal
        pure
        returns (IntentId id)
    {
        id = wrapId(keccak256(abi.encode(_in, out)));
    }

    function wrapId(bytes32 _id) internal pure returns (IntentId wrapped) {
        wrapped = IntentId.wrap(_id);
    }

    function withIdentifier(address inToken_, address outToken_)
        internal
        pure
        returns (Intents memory intent)
    {
        intent.inToken = inToken_;
        intent.outToken = outToken_;
    }
}

// needed to lock user funds for the intent, because if not then there's a possibility the intent fails and create a DOS situation
// where intent keeps failing, so user funds needs to be locked here
contract IntentHolder {
    using IntentLibrary for Intents;

    // user => token => locked balance
    // this is used for locking user funds, if a user makes an intent, the funds will go here
    mapping(address => mapping(address => uint256)) public locked;

    // user => token => locked balance
    // this is used for holding user free balances, after the intent is executed, this is where user funds will go to
    mapping(address => mapping(address => uint256)) public free;

    function withdrawLocked(address token, uint256 amount) external {
        // TODO custom errors
        require(locked[msg.sender][token] >= amount);

        locked[msg.sender][token] -= amount;

        IERC20(token).transfer(msg.sender, amount);
    }

    function withdrawFree(address token, uint256 amount) external {
        // TODO custom errors
        require(free[msg.sender][token] >= amount);

        free[msg.sender][token] -= amount;

        IERC20(token).transfer(msg.sender, amount);

    }
}

contract IntentModule {
    using IntentLibrary for Intents;
    using IntentLibrary for IntentSpecification;

    IntentHolder custody;

    mapping(IntentId => IntentSpecification) public intents;

    // only allow self call
    // TODO : custom errors
    modifier onlySelf() {
        require(msg.sender == address(this));
        _;
    }

    function setCustody(address _custody) external onlySelf {
        custody = IntentHolder(_custody);
    }

    // DOESN'T PERFORM ACTUAL BALANCE CHECKS, INTENT MAY FAIL
    // IT'S ADVISED TO ADD AN INTENT WITHIN OR CLOSE TO MARKET PRICE SINCE NOT DOING SO RISK YOUR ORDER BEING UNFULFILLED
    // SINCE THE INTENT LOOKS AT THE RATIO OF THE IN & OUT AMOUNT AND TRIES TO PARTIALLY FILL YOUR ORDER BASED ON THAT
    function setIntents(
        address inToken_,
        address outToken_,
        uint256 inAmount,
        uint256 outAmount
    ) external onlySelf returns (IntentId id) {
        id = IntentLibrary.withIdentifier(inToken_, outToken_).toId();

        intents[id].inAmount += inAmount;
        intents[id].outAmount += outAmount;
    }

    function fill(
        address inToken,
        address outToken,
        uint256 inAmount,
        uint256 outAmount
    ) external returns (bool success) {
        uint256 fillRatio = MathUtils.calculateRatio(inAmount, outAmount);

        IntentSpecification storage spec = intents[
            IntentLibrary.toId(inToken, outToken)
        ];

        uint256 intentRatio = spec.toRatio();

        // TODO custom errors
        // only allow filling orders if ratio the same
        require(intentRatio >= fillRatio);
    }
}
