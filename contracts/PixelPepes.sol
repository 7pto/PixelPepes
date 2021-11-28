// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';


contract PixelPepes is ERC721Enumerable, Ownable {  
    using Address for address;
    using Strings for uint256;
    
    IERC721 public avaPepe /* = some address*/;
    IERC721 public avaxWildlife /* = some address*/;
    
    // Starting and stopping mint
    bool public mintActive = false;

    // Maximum limit of tokens that can ever exist
    uint256 constant MAX_SUPPLY = 200; 

    // The base link that leads to the image / video of the token
    string public baseTokenURI;
    
    string public baseExtension = ".json";
    
    // token_id redeemed
    mapping(uint => bool) public avaPepeTokenId;
    mapping(uint => bool) public avaxWildlifeTokenId;


    constructor (string memory newBaseURI) ERC721 ("Avax Wildlife", "AXWL") {
        setBaseURI(newBaseURI);
    }

    // Override so the openzeppelin tokenURI() method will use this method to create the full tokenURI instead
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    // See which address owns which tokens
    function tokensOfOwner(address addr) public view returns(uint256[] memory) {
        uint256 tokenCount = balanceOf(addr);
        uint256[] memory tokensId = new uint256[](tokenCount);
        for(uint256 i; i < tokenCount; i++){
            tokensId[i] = tokenOfOwnerByIndex(addr, i);
        }
        return tokensId;
    }

    // Standard mint function
    function mintToken(uint256[] memory avaPepeIds, uint256[] memory avaxWildlifeIds) public {
        uint256 supply = totalSupply();
        require( mintActive, "mint isn't active");
        require(avaPepeIds.length == avaxWildlifeIds.length, "tokens amount mismatch");
        require( supply + avaPepeIds.length <= MAX_SUPPLY, "Can't mint more than max supply" );
        for(uint256 i; i < avaPepeIds.length; i++) {
            require(avaPepe.ownerOf(avaPepeIds[i]) == msg.sender, "does not own the tokens");
            require(avaxWildlife.ownerOf(avaxWildlifeIds[i]) == msg.sender, "does not own the tokens");
        }
        for(uint256 i; i < avaPepeIds.length; i++) {
            require(avaPepeTokenId[avaPepeIds[i]] == false, "token already redeemded against the provided token Ids");
            require(avaxWildlifeTokenId[avaxWildlifeIds[i]] == false, "token already redeemded against the provided token Ids");
        } 
        for(uint256 i; i < avaPepeIds.length; i++) {
            avaPepeTokenId[avaPepeIds[i]] == true;
            avaxWildlifeeTokenId[avaxWildlifeIds[i]] == true;
        } 
        
        for(uint256 i; i < avaPepeIds.length; i++){
            _safeMint(msg.sender, supply + i);
        }
    }
    
    // override to ensure correct tokenURI
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(
        _exists(tokenId),
        "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
            : "";
    }    

    // allow minting
    function setMintActive() public onlyOwner {
        mintActive = true;
    }

    // Set new baseURI
    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }
    
    function setAvaPepeAddress(address _address) external onlyOwner {
        avaPepe = IERC721(_address);
    }
    
    function setAvaxWildlifeAddress(address _address) external onlyOwner {
        avaxWildlife = IERC721(_address);
    }

}





