// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.23;

// We deploy a proxy on top of an existing token implementation contract to save gas
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

// We are just going to assume its uniswap v2
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
 * 4) After X minutes, if the supply isn't already sold or burnt, anyone can ensure its burned. 
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
    //////////////////////////////////////////////////
    // Events 
    //////////////////////////////////////////////////
    
    
    //////////////////////////////////////////////////
    // Storage 
    //////////////////////////////////////////////////
        
    // Prevent outright spam and feed the dev (.001 ETH)
    uint256 public immutable LAUNCH_FEE = 1 ether / 1000;
        
    // used for token pagination
    uint256 public immutable PAGE_SIZE = 20;                // this is arbitrary, which means its wrong. 
    
    // determines the horizon of time that a developer has
    // to either burn or sell the remaining half of the supply.
    // after this point, ANYONE can permissionlessly burn it. 
    uint256 public immutable SNIPER_HORIZON = 30;           // 6 minutes for the dev to consider stomping snipers

    // Need a reference to the uniswap v2 router this program will use.
    address                  public  uniswapV2Router;       // will be different depending on environment

    // We are going to use a proxy to save on deployment costs, even though
    // none of the contracts are going to be upgradeable.
    address                 public   safeTokenImplementation;

    // The registry index for all of the launched tokens. Instead of storing a boolean,
    // we store the block height that the token was launched at. A launch block of zero is
    // considered an invalid token. This data is also used to determine the "stomp horizon"
    // for a coin.
    mapping(address => uint256) public  tokenLaunchBlock;       // quick lookup and verification
    mapping(address => address) public  tokenDevelopers;        // pre-horizon burn/sell permissions
    address[]                   private launchedTokens;         // we want a full index of every token
    
    //////////////////////////////////////////////////
    // Methods 
    //////////////////////////////////////////////////

    /**
     * Constructor
     *
     * Will take a uniswap v2 router. Must not be null.
     * You must be careful because this contract is immutable.
     * Don't fuck it up.
     * 
     * @param _uniswapV2Router the address of the uniswap v2 router you are going to use.
     * @param _safeTokenImplementation the implementation contract for the safe token
     */
    constructor(address _uniswapV2Router, address _safeTokenImplementation) {
        uniswapV2Router = _uniswapV2Router;
        safeTokenImplementation = _safeTokenImplementation;
    }

    /**
     * getLaunchedTokenCount
     *
     * Returns the number of tokens that are created through this factory.
     * Useful to know how many there are to page through them all for display.
     *
     * @return the number of tokens this registry has created
     */
    function getLaunchedTokenCount() public view returns (uint256) {
        return launchedTokens.length;
    }

    /**
     * getLatestPageNumber
     *
     * Tells you which page number to pass into getLaunchedTokens to
     * get the latest coins that have been launched.
     *
     * @return a hopefully increasing number over time
     */ 
    function getLatestPageNumber() public view returns (uint256) {
        return _latestPage(); 
    }

    /**
     * getLaunchedTokens
     *
     * Will return an array of addresses up to 20 in length, based on the
     * page number provided, starting from 0. The most "current" page will be
     * getLaunchedTokenCount() / 20 floored down to the nearest integer, can
     * can be crawled back to page 0 from there chronologically.
     *
     * @param page the page of results you are looking for
     */
    function getLaunchedTokens(uint256 page) public view returns (address[] memory) {
        // guard against stupid things
        require(page <= _latestPage(), 'PAGE_NUMBER_OUT_OF_RANGE');

        // this is likely expensive, mainly used by frontends
        // and not by contracts as this is gassy
        uint256 start = page * PAGE_SIZE;
        address[] memory subsection = new address[](PAGE_SIZE);
        for (uint256 i = start; i < (start+PAGE_SIZE); i++) {
            subsection[i - start] = launchedTokens[i];
        }

        return subsection;
    }

    /**
     * launchToken
     *
     * Called by a developer to launch a token. Once this function returns,
     * the token is likely live on uniswap and the stomp option is active.
     *
     * @param name    The name of the token, aka "Shibu Inu" or "Roflcopter"
     * @param ticker  Come on bro, whats the ticker sons? Consider SONS.
     *
     * @return the newly minted token address
     */
    function launchToken(string calldata name, string calldata ticker) payable external returns (address) {
        // deploy the token. use a proxy to save up to 5x on the gas 
        
        // store the developer and index it as a token we've launched

        // at this point, we should have 1B of the supply, invariant
    
        // add the liquidity to uniswap

        // burn the LP token
    }

    /**
     * stompSnipers
     *
     * This method is called by the token developer within
     * SNIPER_HORIZON blocks of launch, to sell the remaining 50% of
     * the supply to punish the snipers and potentially cause them
     * to force sell at a loss.
     *
     * This method will revert if the caller is not the token developer
     * or if the horizon for that token has already passed, in which case,
     * only a burn is possible.
     *
     * @param token the address of the token you want to stomp snipers on
     */ 
    function stompSnipers(address token) external {
        // make sure that the caller is the developer
        require(msg.sender == tokenDevelopers[token], 'WHERE_IS_DEV');

        // ensure that it is properly time to be able to do this
        require(block.number <= tokenLaunchBlock[token] + SNIPER_HORIZON, 'TOO_LATE');

        // sell all of the tokens of that type that are sitting in this contract 
    }

    /**
     * burnSupply
     *
     * This function can either be called by the dev before the horizon,
     * or by anyone after the horizon.
     *
     * @param token the token you want to burn the remaining supply for
     */
    function burnSupply(address token) external {
        
    }

    //////////////////////////////////////////////////
    // INTERNAL FUNCTIONS
    //////////////////////////////////////////////////
    function _latestPage() internal view returns (uint256) {
        return launchedTokens.length / PAGE_SIZE;
    }
}
