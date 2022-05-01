//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @notice Query if a contract implements an interface
 * @dev Interface identification is specified in ERC-165. This function
 * uses less than 30,000 gas.
 */
interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}