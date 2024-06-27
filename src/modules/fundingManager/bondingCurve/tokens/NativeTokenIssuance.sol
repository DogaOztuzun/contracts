// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Address} from "@oz/utils/Address.sol";

import "../interfaces/INativeTokenIssuance.sol";
import "../interfaces/INativeMinter.sol";

contract NativeTokenIssuance is INativeTokenIssuance {
    using Address for address payable;

    INativeMinter public constant NATIVE_MINTER = INativeMinter(0x0200000000000000000000000000000000000001);

     /**
     * @notice The address where native tokens are sent in order to be burned to bridge to other chains.
     *
     * @dev This address is distinct from {BURNED_TX_FEES_ADDRESS} so that the amount of burned transaction
     * fees and burned bridged amounts can be tracked separately.
     * This address was chosen arbitrarily.
     */
    address public constant BURNED_FOR_BONDINGCURVE_ADDRESS = 0x0100000000000000000000000000000000010203;

    /**
     * @notice Total number of tokens minted by this contract through the native minter precompile.
     */
    uint256 public totalMinted;

    constructor() {
        
    }

    fallback() external payable {
        // This function is executed on a call to the contract if none of the other
        // functions match the given function signature, or if no data is supplied at all
    }

    receive() external payable {
        // This function is executed when a contract receives plain Ether (without data)
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function mint(address _to, uint _amount) external {
        // Optional: Add any access control or validation if needed
        require(_to != address(0), "Invalid recipient address");
        // require(_amount > 0, "Amount must be greater than zero");

        totalMinted += _amount;

        // Calls NativeMinter precompile through INativeMinter interface.
        NATIVE_MINTER.mintNativeCoin(_to, _amount);
    }

    function burn(address _from, uint _amount) external {
        payable(BURNED_FOR_BONDINGCURVE_ADDRESS).sendValue(_amount);
    }

    /**
     * @dev See {INativeTokenSpoke-totalNativeAssetSupply}.
     *
     * Note: {INativeTokenSpoke-totalNativeAssetSupply} should not be confused with {IERC20-totalSupply}
     * {INativeTokenSpoke-totalNativeAssetSupply} returns the supply of the native asset of the chain,
     * accounting for the amounts that have been bridged in and out of the chain as well as burnt transaction
     * fees. The {initialReserveBalance} is included in this supply since it is in circulation on this
     * chain even prior to it being backed by collateral on the hub instance.
     * {IERC20-totalSupply} returns the supply of the native asset held by this contract
     * that is represented as an ERC20.
     */
    function totalNativeAssetSupply() public view returns (uint256) {
        uint256 burned = BURNED_FOR_BONDINGCURVE_ADDRESS.balance;
        uint256 created = totalMinted;
        return created - burned;
    }
}