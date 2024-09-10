// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.23;

// We are going to use a proxy-ready ERC20
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * SafeToken
 *
 * A simple ERC20 token contract that mints a 1B supply token
 * and sends it back to the deployer.
 *
 * While it looks like this contract is upgradeable, in practice it will
 * not be. We will deploy this as an implementation contract, and then
 * deploy a new instanced ERC1967 proxy for each individual safe token.
 *
 * The motivation behind this is to save chain-space and gas when
 * launching a token.
 *
 * The decimals will always use the default of 18. 
 */
contract SafeToken is Initializable, ERC20Upgradeable {
    /**
     * Initialize 
     *
     * This is called from a ERC1967 proxy deployment
     * by the token factory.
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
    function burnMe() external {
        _burn(msg.sender, balanceOf(msg.sender)); 
    }
}
