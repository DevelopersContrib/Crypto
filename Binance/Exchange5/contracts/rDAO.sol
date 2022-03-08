pragma solidity ^0.5.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";


contract rDAO is ERC20, ERC20Detailed {
    
    uint8 public constant DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(DECIMALS));

    constructor () public ERC20Detailed("REIT Token", "REIT", DECIMALS) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}