pragma solidity ^0.5.0;

import "@openzeppelin/contracts/access/Roles.sol";
import "@openzeppelin/contracts/crowdsale/Crowdsale.sol";

contract RDAOCrowdsale is Crowdsale{
  using Roles for Roles.Role;

  Roles.Role private _owners;

  uint256 private _changeableRate;

  constructor(uint256 initialRate, address payable wallet, IERC20 tokenAddr, address ownerAddr)
  Crowdsale(initialRate, wallet, tokenAddr)
  public
  {
    _owners.add(ownerAddr);

    _changeableRate = initialRate;
  }

  function setRate(uint256 newRate) public
  {
    require(_owners.has(msg.sender), "DOES_NOT_HAVE_RATE_SETTER_ROLE");
    _changeableRate = newRate;
  }

  function rate() public view returns (uint256) {
    return _changeableRate;
  }

  function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
    return weiAmount.mul(_changeableRate);
  }
}