// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Vm} from "forge-std/Vm.sol";
import {
    SuperfluidTester,
    Superfluid,
    ConstantFlowAgreementV1,
    CFAv1Library,
    SuperTokenFactory
} from "./SuperfluidTester.sol";
import {IMySuperToken} from "../interfaces/IMySuperToken.sol";
import {MySuperToken} from "../MySuperToken.sol";

/// @title Example Super Token Test
/// @author jtriley.eth
/// @notice For demonstration only. You can delete this file.
contract MySuperTokenTest is SuperfluidTester {

    /// @dev This is required by solidity for using the CFAv1Library in the tester
    using CFAv1Library for CFAv1Library.InitData;

    /// @dev VM for cheats `address(bytes20(uint160(uint256(keccak256('hevm cheat code')))))`
    Vm private vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    /// @dev Superfluid contracts to use

    /// @dev Example Super Token to test
    IMySuperToken internal token;

    /// @dev Constants for Testing
    uint256 internal constant initialSupply = 100_000_000e18;
    address internal constant admin = address(1);
    address internal constant someOtherPerson = address(2);

    constructor() SuperfluidTester(vm, admin) {
        
    }

    function setUp() public {
        // NOTE: If you're copy-pasting this for your own test, you can safely delete the rest of
        // this function :)

        // Become admin
        vm.startPrank(admin);

        // Deploy MySuperToken
        token = IMySuperToken(address(new MySuperToken()));

        // Upgrade MySuperToken with the SuperTokenFactory
        superTokenFactory.initializeCustomSuperToken(address(token));

        // initialize MySuperToken
        token.initialize("Super Mega Token", "SMT", initialSupply);

        vm.stopPrank();
    }

    /// @dev Tests metadata functions
    function testMetaData() public {
        assertEq(token.name(), "Super Mega Token");
        assertEq(token.symbol(), "SMT");
        assertEq(token.decimals(), 18);
    }

    /// @dev Tests transfer function
    function testTransfer() public {
        vm.prank(admin);
        token.transfer(someOtherPerson, 10);

        assertEq(token.balanceOf(admin), initialSupply - 10);
        assertEq(token.balanceOf(someOtherPerson), 10);
    }

    /// @dev Tests stream creation
    function testStreamCreation() public {
        vm.warp(0);
        vm.startPrank(admin);

        cfaLib.flow(
            someOtherPerson,
            token,
            1e18 // flowRate
        );

        (, int96 flowRate, , ) = cfa.getFlow(
            token,
            admin,
            someOtherPerson
        );

        assertEq(flowRate, 1e18);
    }
}
