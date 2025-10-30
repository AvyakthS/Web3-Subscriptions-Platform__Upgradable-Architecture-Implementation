// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {SubscriptionPlan} from "./SubscriptionPlan.sol";

contract SubscriptionManagerV1 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    mapping(address => address[]) public creatorToPlans;
    address[] public allPlans;

    event PlanCreated(
        address indexed creator,
        address indexed planAddress,
        address token,
        uint256 price,
        uint256 duration
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function createSubscriptionPlan(
        address _token,
        uint256 _price,
        uint256 _duration,
        address _beneficiary
    ) external {
        require(_token != address(0), "Token cannot be zero address");
        require(_beneficiary != address(0), "Beneficiary cannot be zero address");
        require(_price > 0, "Price must be greater than zero");
        require(_duration > 0, "Duration must be greater than zero");
        SubscriptionPlan newPlan = new SubscriptionPlan(
            msg.sender, _token, _price, _duration, _beneficiary
        );
        address newPlanAddress = address(newPlan);
        creatorToPlans[msg.sender].push(newPlanAddress);
        allPlans.push(newPlanAddress);
        emit PlanCreated(msg.sender, newPlanAddress, _token, _price, _duration);
    }

    function getPlansByCreator(address _creator) external view returns (address[] memory) {
        return creatorToPlans[_creator];
    }

    function getPlanCount() external view returns (uint256) {
        return allPlans.length;
    }
}