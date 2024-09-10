// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * SafeToken
 *
 * A simple ERC20 token contract that mints a 1B supply token
 * and sends it back to the deployer.
 *
 * The decimals will always use the default of 18. 
 */
contract SafeToken is ERC20 {
    /**
     * Constructor
     *
     * @param _name   the name of the token
     * @param _symbol the ticker of the token
     */
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        // mint 1B tokens (assuming 18 point decimals) back to the caller
        _mint(msg.sender, 1e27); 
    }
}
