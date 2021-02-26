pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract RdaoERC721 is Context, AccessControl, ERC721 {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BASEURI_SETTER_ROLE = keccak256(
        "BASEURI_SETTER_ROLE"
    );

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor(string memory name, string memory symbol, string memory baseURI) public ERC721(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(BASEURI_SETTER_ROLE, _msgSender());

        _setBaseURI(baseURI);
    }

    function mint(address to) public {
        require(
            hasRole(MINTER_ROLE, msg.sender),
            "MyERC721: account does not have minter role"
        );
        _tokenIds.increment();

        uint256 newTokenId = _tokenIds.current();
        _mint(to, newTokenId);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "MyERC721: URI query for nonexistent token");

        return string(abi.encodePacked(baseURI(), Strings.fromUint256(tokenId)));
    }

    function setBaseURI(string memory baseURI) public {
        require(
            hasRole(BASEURI_SETTER_ROLE, msg.sender),
            "MyERC721: account does not have setter role"
        );
        _setBaseURI(baseURI);
    }
}


