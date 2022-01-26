pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EshToken is ERC20, Ownable {

    constructor() ERC20("EshToken", "ESH") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /*function _transferOwnership(address newOwner) public onlyOwner {
        transferOwnership(newOwner);
    }*/
}