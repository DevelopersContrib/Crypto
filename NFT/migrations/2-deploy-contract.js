var RdaoERC721 = artifacts.require("RdaoERC721");
module.exports = function(deployer) {
  deployer.deploy(RdaoERC721,"RealtyDao NFT","RDAO","https://realtydao.com/NFT/");
};