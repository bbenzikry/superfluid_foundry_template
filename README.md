# Superfluid Foundry Starter Template

This is a foundry template for developing and testing Superfluid-related contracts such as Super
Tokens, Super Apps, and other contracts that call Superfluid agreements.

## Set Up

NOTE: You will need yarn (or npm) and foundry to use this project.

To get started, clone this repo:

```bash
git clone __TODO__
```

Next, install dependencies. At the time of writing, Superfluid _MUST_ be installed as node modules.

```bash
yarn
# Or `npm install` if you prefer npm
```

Next, try running the generic test:

```bash
forge test
```

## Project Layout

The majority of the project layout is as `forge init <name>` creates it. The main difference is the
node dependencies. For this, the `package.json` includes the Superfluid contracts. The
`foundry.toml` file contains has `node_modules` in the `libs` array, which tells the compiler where
to find dependencies. The `libraries` array contains a linking configuration for the
`InsantDistributionAgreementV1` to the `SlotsBitmapLibrary` external contract. For the purpose of
testing, the address of the `SlotsBitmapLibrary` is deterministically set to
`0x0101010101010101010101010101010101010101`. More on this under 'Etching'. The `remappings.txt`
file and the `.vscode` directory are for VSCode compatibility on imports. You don't need this, but
if you remove it, you'll get visual errors that won't actually show up in tests.

The `SuperfluidFramework.t.sol` is the bread and butter here. The framework contains every contract
in the Superfluid ecosystem necessary to run automated tests. To access, you'll need to create an
instance of the contact with a `Vm` contract for cheats and etching, and an `admin` address, to whom
the admin priviledges go. To access the contracts, deploy the framework and fetch the applicable
contracts as follows.

```solidity
// omitting imports for brevity

contract YourTestContractNameHere {

    // Vm contract and admin address
    Vm internal vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    address internal admin = address(1);

    // You probably don't need all of these, remove the unused ones as needed
    Superfluid internal host;
    ConstantFlowAgreementV1 internal cfa;
    InstantDistributionAgreementV1 internal ida;
    SuperTokenFactory superTokenFactory;

    function setUp() public {

        // Deploy Framework and fetch the relevant contracts
        (host, cfa, ida, superTokenFactory) = new SuperfluidFramework(vm, admin).framework();

    }

    // tests ...

}
```

For more, see `./src/test/MySuperToken.t.sol`.

## Etching

NOTE: You don't need to read this section unless you _really_ want to know the internals of the test
framework deployment.

Etching allows you use Foundry cheat codes to force specific bytecode onto a given address.This is
used in the `SuperfluidFramework` deployment in two places.

First is the `ERC1820Registry` since the registry is always deployed at the same address, regardless
of the network. The simplest choice for now is to take the `ERC1820Registry` bytecode and etch it to
the address: `0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24`.

Second is the `SlotsBitmapLibrary` for the `InstantDistributionAgreementV1` contract. Since the IDA
uses the SB Lib as an externally linked library, the easiest way to handle this in Forge is to use
a deterministic address in the `libraries` in the `foundry.toml` file, which means we have to etch
the SB Lib bytecode onto the deterministic address in the config. This allows Forge to link the
libraries.

## Troubleshooting

### `forge test` Panick

POV: You're getting a panick that looks something like this when running tests:

```
The application panicked (crashed).
Message:  No target contract
Location: utils/src/lib.rs:113
```

This is likely because of a possible Forge bug with library linking. To fix this, try running the
following command instead of `forge test`

```bash
forge test --libraries "@superfluid-finance/ethereum-contracts/contracts/agreements/InstantDistributionAgreementV1.sol:SlotsBitmapLibrary:0x0101010101010101010101010101010101010101"
```

This overrides the `foundry.toml` config, however, subsequent runs of just `forge test` should no
longer panick. I have no idea why this does this, but will be investigating further and creating a
github issue in the future.
