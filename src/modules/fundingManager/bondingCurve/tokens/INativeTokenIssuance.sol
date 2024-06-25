// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./INativeMinter.sol";

interface INativeTokenIssuance {

    function decimals() external pure returns (uint8);

    /// @notice Mints new tokens
    /// @param _to The address of the recipient.
    /// @param _amount The amount of tokens to mint.
    function mint(address _to, uint _amount) external;

    /// @notice Burns tokens
    /// @param _from The address of the owner.
    /// @param _amount The amount of tokens to burn.
    function burn(address _from, uint _amount) external;
}