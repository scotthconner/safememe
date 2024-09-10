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
     * consructor 
     *
     * @param name   the name of the token
     * @param symbol the ticker of the token
     */
    function initialize(string memory name, string memory symbol) external {
        __ERC20_init(name, symbol);
        // mint 1B tokens (assuming 18 point decimals) back to the caller
        _mint(msg.sender, 1e27); 
    }

    /**
     * burnMe
     *
     * Anyone can call this function to have the token contract burn all of the tokens
     * out of their wallet, reducing supply. Mainly, this is called by the token factory
     * to burn the supply that was retained in the factory.
     */
    function burnMe() external returns (uint256) {
        _burn(msg.sender, balanceOf(msg.sender)); 
    }
}
