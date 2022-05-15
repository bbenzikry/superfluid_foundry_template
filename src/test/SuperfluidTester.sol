// SPDX-License-Identifier: AGPLv3
pragma solidity ^0.8.0;

import {Vm} from "forge-std/Vm.sol";
import {DSTest} from "ds-test/test.sol";
import {IERC1820Registry} from "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
import {
    Superfluid,
    ConstantFlowAgreementV1,
    InstantDistributionAgreementV1,
    SuperTokenFactory,
    SuperfluidFrameworkDeployer
} from "@superfluid-finance/ethereum-contracts/contracts/utils/SuperfluidFrameworkDeployer.sol";
import {
    ERC1820RegistryCompiled
} from "@superfluid-finance/ethereum-contracts/contracts/libs/ERC1820RegistryCompiled.sol";
import {CFAv1Library} from "@superfluid-finance/ethereum-contracts/contracts/apps/CFAv1Library.sol";
import {IDAv1Library} from "@superfluid-finance/ethereum-contracts/contracts/apps/IDAv1Library.sol";


/// @title Superfluid Framework
/// @author jtriley.eth
/// @notice This is NOT for deploying public nets, but rather only for tesing envs
contract SuperfluidTester is DSTest {

    SuperfluidFrameworkDeployer internal immutable sfDeployer;

    /// @dev Everything you need from framework is in it
    SuperfluidFrameworkDeployer.Framework internal sf;

    CFAv1Library.InitData internal cfaLib;
    IDAv1Library.InitData internal idaLib;

    /// @notice Deploys everything... probably
    /// @param vm Virtual Machine for cheat codes
    /// @param admin Desired address of Admin
    constructor(Vm vm, address admin) {
        // everything will be deployed as if `admin` was the message sender of each
        vm.startPrank(admin);

        // Deploy ERC1820Registry by 'etching' the bytecode into the address
        // mother of god this can not be real
        vm.etch(ERC1820RegistryCompiled.at, ERC1820RegistryCompiled.bin);

        sfDeployer = new SuperfluidFrameworkDeployer();
        sf = sfDeployer.getFramework();

        vm.stopPrank();
    }
}
