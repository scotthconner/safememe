// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

/**
 * TokenFactory
 *
 * This high level contract will be the entry point for the safe meme
 * coin launcher. The process is as follows:
 *
 * 1) Coin developer supplies coin metadata, as well as any amount of initial liquidity
 *    they'd like, with some reasonable minimum like .05 ETH.
 * 2) In a single transaction, the coin is minted, with 50% of the supply added to LP along
 *    with the ETH, and the other 50% of the supply contained within this factory.
 * 3) Up to X minutes after launch, the dev can choose to: 
 *              a) burn the 50% supply contained within this contract.
 *              b) sell the 50% supply and burn all the proceeds as a way to kill snipers
 * 4) After X minutes, anyone can "stomp" the supply and burn the funds.
 *
 * This has the following benefits:
 *   - Tokens can be verified as immutable contracts that are safe, and not honey pots.
 *   - Tokens immediately have locked liquidity and cannot be rugged.
 *   - Tokens are available on Uniswap, and compatible with all front-ends, screeners, and bots.
 *
 * The goal is to strike a balance on the perceived safety of pump.fun type coin launchers,
 * but get the immediate benefits of global liquidity with some sniper safeguards built in. 
 */
contract TokenFactory {
    // Need a reference to the uniswap v2 router this program will use.
    address                  public  uniswapV2Router;

    // The registry index for all of the launched tokens
    mapping(address => bool) public  isTokenVerified;       // quick lookup and verification
    address[]                private launchedTokens;        // we want a full index of every token

    /**
     * Constructor
     *
     * Will take a uniswap v2 router. Must not be null.
     * You must be careful because this contract is immutable.
     * Don't fuck it up.
     * 
     * @param _uniswapV2Router the address of the uniswap v2 router you are going to use.
     */
    constructor(address _uniswapV2Router) {
        uniswapV2Router = _uniswapV2Router;
    }
}
