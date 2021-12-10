pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CTBToken is ERC20, Ownable {

    constructor() ERC20("CTBToken", "CTB") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /*function _transferOwnership(address newOwner) public onlyOwner {
        transferOwnership(newOwner);
    }*/
}