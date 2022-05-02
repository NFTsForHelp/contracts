// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Address.sol";


contract NFTSFORHELPC1 is ERC721, IERC2981, ReentrancyGuard, Ownable {
  using Counters for Counters.Counter;

  uint256 public constant MAX_SUPPLY = 11000;
  string private customBaseURI;
  string private customContractURI;
  Counters.Counter private supplyCounter;
  
  
  constructor(string memory customBaseURI_, string memory customContractURI_) ERC721("NFTSFORHELPC1", "NFTSFHC1") {
    customBaseURI = customBaseURI_;
    customContractURI = customContractURI_;
  	mint(100);
  }

  function mint(uint256 count) public nonReentrant onlyOwner {
    for (uint256 i = 0; i < count; i++) {
      supplyCounter.increment();
      _mint(msg.sender, totalSupply());
    }
  }

  function totalSupply() public view returns (uint256) {
    return supplyCounter.current();
  }

    /** URI HANDLING **/


  mapping(uint256 => string) private tokenURIMap;

  function setTokenURI(uint256 tokenId, string memory tokenURI_)  external  onlyOwner
  {
    tokenURIMap[tokenId] = tokenURI_;
  }

  function setBaseURI(string memory customBaseURI_) external onlyOwner {
    customBaseURI = customBaseURI_;
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return customBaseURI;
  }

  function tokenURI(uint256 tokenId) public view override  returns (string memory)
  {
    string memory tokenURI_ = tokenURIMap[tokenId];

    if (bytes(tokenURI_).length > 0) {
      return tokenURI_;
    }

    return string(abi.encodePacked(super.tokenURI(tokenId), ".json"));
  }
  

  /** PAYOUT **/

  address private payoutAddressNGO = 0x0000000000000000000000000000000000000000;

  function setBasePayoutAddressNGO(address payoutAddressNGO_) external onlyOwner {
    payoutAddressNGO = payoutAddressNGO_;
  }

  function _basePayoutAddressNGO() internal view virtual returns (address ngos) {
    return payoutAddressNGO;
  }

  function withdraw() public nonReentrant onlyOwner {
    uint256 balance = address(this).balance;

    Address.sendValue(payable(owner()), balance * 70 / 100);

    Address.sendValue(payable(payoutAddressNGO), balance * 30 / 100);
  }

  /** ROYALTIES **/

  function royaltyInfo(uint256, uint256 salePrice) external view override
    returns (address receiver, uint256 royaltyAmount)
  {
    return (address(this), (salePrice * 100) / 10000);
  }


  function setCustomContractURI(string memory customContractURI_) external onlyOwner {
    customContractURI = customContractURI_;
  }
   
  function contractURI() public view returns (string memory) {
    return customContractURI;
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC721, IERC165)
    returns (bool)
  {
    return (
      interfaceId == type(IERC2981).interfaceId ||
      super.supportsInterface(interfaceId)
    );
  }
}
