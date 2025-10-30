// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract SubscriptionPlan is ReentrancyGuard {
    using SafeERC20 for IERC20;

    // --- State Variables (Naming convention updated) ---
    address public immutable OWNER;
    IERC20 public immutable TOKEN;
    uint256 public immutable PRICE;
    uint256 public immutable DURATION;
    address public immutable BENEFICIARY;

    struct Subscription {
        uint256 expiry;
        bool active;
    }

    mapping(address => Subscription) public subscriptions;

    // --- Events ---
    event Subscribed(address indexed user, uint256 expiry);
    event SubscriptionPaused(address indexed user);
    event SubscriptionResumed(address indexed user, uint256 newExpiry);

    constructor(
        address _owner,
        address _token,
        uint256 _price,
        uint256 _duration,
        address _beneficiary
    ) {
        OWNER = _owner;
        TOKEN = IERC20(_token);
        PRICE = _price;
        DURATION = _duration;
        BENEFICIARY = _beneficiary;
    }

    // --- Core Functions ---
    function subscribe() external nonReentrant {
        uint256 currentAllowance = TOKEN.allowance(msg.sender, address(this));
        require(currentAllowance >= PRICE, "Check token allowance");

        // SECURITY FIX: Use safeTransferFrom to check return value
        TOKEN.safeTransferFrom(msg.sender, BENEFICIARY, PRICE);

        Subscription storage sub = subscriptions[msg.sender];
        bool wasPaused = sub.expiry > 0 && !sub.active;
        uint256 newExpiry = block.timestamp > sub.expiry
            ? block.timestamp + DURATION
            : sub.expiry + DURATION;
        sub.expiry = newExpiry;
        sub.active = true;

        if (wasPaused) {
            emit SubscriptionResumed(msg.sender, newExpiry);
        } else {
            emit Subscribed(msg.sender, newExpiry);
        }
    }

    function cancel() external {
        require(subscriptions[msg.sender].active, "Not subscribed");
        subscriptions[msg.sender].active = false;
        emit SubscriptionPaused(msg.sender);
    }

    // --- View Functions ---
    function isSubscriptionActive(address _user) external view returns (bool) {
        Subscription memory sub = subscriptions[_user];
        return sub.active && sub.expiry > block.timestamp;
    }
}