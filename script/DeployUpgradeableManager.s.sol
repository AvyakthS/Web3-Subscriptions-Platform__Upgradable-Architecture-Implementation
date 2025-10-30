// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {SubscriptionManagerV1} from "../src/SubscriptionManagerV1.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployUpgradeableManager is Script {
    function run() external returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        SubscriptionManagerV1 implementation = new SubscriptionManagerV1();
        bytes memory initData = abi.encodeWithSignature("initialize()");
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            initData
        );
        vm.stopBroadcast();
        return address(proxy);
    }
}