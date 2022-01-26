pragma solidity ^0.5.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Mintable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";

contract EshToken is ERC20, ERC20Detailed, ERC20Mintable, ERC20Pausable, ERC20Burnable{
    uint8 public constant DECIMALS = 18;
    constructor (string memory name, string memory symbol, 
		address mintToDan, uint256 DAN_SUPPLY, address mintToOwner, uint256 OWNER_SUPPLY, address mintToReserve, uint256 RESERVE_SUPPLY) public ERC20Detailed(name, symbol, DECIMALS) {
        
		_mint(mintToDan, DAN_SUPPLY * (10 ** uint256(DECIMALS)));
		
		if(OWNER_SUPPLY>0){
			_mint(mintToOwner, OWNER_SUPPLY * (10 ** uint256(DECIMALS)));
		}
		
		if(RESERVE_SUPPLY>0){
			_mint(mintToReserve, RESERVE_SUPPLY * (10 ** uint256(DECIMALS)));
		}
    }
}