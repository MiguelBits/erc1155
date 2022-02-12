// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



// Helper we wrote to encode in Base64
import "./Base64.sol";
// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Galaxy_heroes is ERC1155{
    
    //CONSTANTS
    uint constant hero = 1;
    uint constant item = 1;

    //NFT associated with a heroTokenId_
    mapping(uint256 => NFT) public heroTokenId_ToNFT;
    mapping(uint256 => NFT) public itemTokenId_ToNFT;

    mapping(uint => address) public heroTokenId_ToOwner;
    mapping(uint => address) public itemTokenId_ToOwner;

    mapping(address => uint[]) public NFTsAtAddress;

    modifier isNotStaked(uint id){
        require(getNFT_hero_staked(id) == false);
        _;
    }
    modifier isStaked(uint id){
        require(getNFT_hero_staked(id) == true);
        _;
    }
    modifier isNftOwner(uint id){
        require(heroTokenId_ToOwner[id] == msg.sender);
        _;
    }

    struct NFT{
        string name;
        string imageURI;  
        uint stars;
        bool staked;
    }

    function stake(uint id) public isNotStaked(id) isNftOwner(id){
        heroTokenId_ToNFT[id].staked = true;
        heroTokenId_ToNFT[id].stars += 1;
    }

    function unstake(uint id) public isStaked(id) isNftOwner(id){
        heroTokenId_ToNFT[id].staked = false;
        heroTokenId_ToNFT[id].stars += 1;
    }
    //CREATION
    //create decks / boosters
    //nft on chain
    NFT[] hero_collection;
    
    function create() internal{
      hero_collection.push(NFT("Dark_Girl","img1",6,false));
      hero_collection.push(NFT("Dark_Magician","img1",6,false));
      hero_collection.push(NFT("Dark_Girl","img1",6,false));
      hero_collection.push(NFT("Dark_Girl","img1",6,false));
      hero_collection.push(NFT("Dark_Girl","img1",6,false));
      hero_collection.push(NFT("Dark_Girl","img1",6,false));
      hero_collection.push(NFT("Dark_Girl","img1",6,false));
      hero_collection.push(NFT("Dark_Girl","img1",6,false));
      hero_collection.push(NFT("Dark_Girl","img1",6,false));
      hero_collection.push(NFT("Dark_Girl","img1",6,false));
    }


    constructor() ERC1155("https://raw.githubusercontent.com/mcruzvas/react_web3/main/metadata/{id}.json") {
        create();
        //no of NFTs in deployed in the blockchain
    }

    //MINTERS
    //function to use random Number TODO
    function finishMint(uint i) public {        
        _mint(msg.sender, hero,1,"");

        heroTokenId_ToNFT[hero] = hero_collection[i];
        NFTsAtAddress[msg.sender].push(hero);
        heroTokenId_ToOwner[hero] = msg.sender;
        
    }
    function itemMint() public{
        require(balanceOf(msg.sender,hero) > 0,"you need have a Mine");
        _mint(msg.sender, item,1,"");
    }

    //GETS
    function nftAccount() public view returns(uint[] memory arr){
        return NFTsAtAddress[msg.sender];
    }
    //staked
    function getNFT_hero_staked(uint id) public view returns(bool hero_staked){
        return heroTokenId_ToNFT[id].staked;
    }
    //names
    function getNFT_item_name(uint id) public view returns(string memory name){
        return itemTokenId_ToNFT[id].name;
    }
    function getNFT_hero_name(uint id) public view returns(bool name){
        return heroTokenId_ToNFT[id].name;
    }
    //stars
    function getNFT_item_stars(uint id) public view returns(string memory stars){
        return itemTokenId_ToNFT[id].stars;
    }
    function getNFT_hero_stars(uint id) public view returns(bool stars)
        return heroTokenId_ToNFT[id].stars;
    }
    

}
