pragma solidity ^0.5.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";

contract EshToken is ERC20, ERC20Detailed, ERC20Burnable{
    
    uint8 public constant DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 1000000 * (10 ** uint256(DECIMALS));

    constructor () public ERC20Detailed("ESH Token", "ESH", DECIMALS) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}