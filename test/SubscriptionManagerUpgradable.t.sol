// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import {SubscriptionManagerV1} from "../src/SubscriptionManagerV1.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {MockUSDC} from "./MockUSDC.sol";

contract SubscriptionManagerUpgradableTest is Test {
    SubscriptionManagerV1 public manager;
    MockUSDC public usdc;
    address public proxyAddress;
    address owner = vm.addr(1);
    address creator = address(0x2);
    address beneficiary = address(0x3);

    function setUp() public {
        // --- FIX START ---
        // Use startPrank to make all subsequent calls from the 'owner' address
        vm.startPrank(owner);

        SubscriptionManagerV1 implementation = new SubscriptionManagerV1();
        bytes memory initData = abi.encodeWithSignature("initialize()");
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initData);
        proxyAddress = address(proxy);
        manager = SubscriptionManagerV1(proxyAddress);

        // Stop the prank after setup is complete
        vm.stopPrank();
        // --- FIX END ---

        usdc = new MockUSDC();
        usdc.mint(creator, 1000 * 10**6);
    }

    function test_InitialOwnerIsDeployer() public view {
        assertEq(manager.owner(), owner);
    }

    function test_CreatePlan_Success() public {
        vm.prank(creator);
        manager.createSubscriptionPlan(address(usdc), 5 * 10**6, 30 days, beneficiary);
        address[] memory plans = manager.getPlansByCreator(creator);
        assertEq(plans.length, 1);
        assertTrue(plans[0] != address(0));
    }
}