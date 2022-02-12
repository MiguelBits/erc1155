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
    uint constant private coin = 100000;
    using Counters for Counters.Counter;
    Counters.Counter private _heroTokenIds;
    Counters.Counter private _itemTokenIds;

    //NFT associated with a TokenId_                    MAPPINGS
    mapping(uint256 => NFT) public heroTokenId_ToNFT;
    mapping(uint256 => NFT) public itemTokenId_ToNFT;

    mapping(uint => address) public heroTokenId_ToOwner;
    mapping(uint => address) public itemTokenId_ToOwner;

    mapping(address => uint[]) public NFTsAtAddress;
    mapping(uint => uint) public tokenId_stakeTimeEnd;

    //MODIFIERS
    modifier isNotStaked(uint id){
        require(getNFT_hero_staked(id) == false,"UnStake is required for this tx");
        _;
    }
    modifier isStaked(uint id){
        require(getNFT_hero_staked(id) == true,"Stake is required for this tx");
        _;
    }
    modifier isNftOwner(uint id){
        require(heroTokenId_ToOwner[id] == msg.sender, "You are not the owner of this Hero!");
        _;
    }
    //STRUCT
    struct NFT{
        string name;
        string imageURI;  
        uint stars;
        bool staked;
    }

    //STAKE
    function stake(uint id) public isNotStaked(id) isNftOwner(id){
        heroTokenId_ToNFT[id].staked = true;
        heroTokenId_ToNFT[id].stars += 1;
        //lockup time period
        tokenId_stakeTimeEnd[id] = block.timestamp + 60;
    }

    function unstake(uint id) public isStaked(id) isNftOwner(id){
        //lockup time period
        require(block.timestamp > tokenId_stakeTimeEnd[id],"Need more time!");
        heroTokenId_ToNFT[id].staked = false;
        _mint(msg.sender, coin,100000000,"");
    }

    //CREATION
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
        _heroTokenIds.increment();
        _itemTokenIds.increment();
    }

    //MINTERS
    //function to use random Number TODO
    function heroMint(uint i) public {   
        uint tokenId = _heroTokenIds.current();
     
        _mint(msg.sender, tokenId,1,"");

        heroTokenId_ToNFT[tokenId] = hero_collection[i];
        NFTsAtAddress[msg.sender].push(tokenId);
        heroTokenId_ToOwner[tokenId] = msg.sender;
        _heroTokenIds.increment();
        
    }
    function itemMint() public{
        uint tokenId = _itemTokenIds.current();

        require(balanceOf(msg.sender,tokenId) > 0,"you need have a Heroe");
        _mint(msg.sender, tokenId,1,"");
        _itemTokenIds.increment();
    }

    //GETS
    //account specific
    function coinBalance() public view returns(uint coins){
        return balanceOf(msg.sender,coin);
    }
    function nftAccount() public view returns(uint[] memory arr){
        return NFTsAtAddress[msg.sender];
    }
    //staked
    function getNFT_hero_staked(uint id) public view returns(bool hero_staked){
        return heroTokenId_ToNFT[id].staked;
    }
    //staked - lockup time period
    function getStakedTimedLeft(uint id) public view returns(uint timeLeft){
        return tokenId_stakeTimeEnd[id] - block.timestamp;
    }
    //names
    function getNFT_item_name(uint id) public view returns(string memory name){
        return itemTokenId_ToNFT[id].name;
    }
    function getNFT_hero_name(uint id) public view returns(string memory name){
        return heroTokenId_ToNFT[id].name;
    }
    //stars
    function getNFT_item_stars(uint id) public view returns(uint stars){
        return itemTokenId_ToNFT[id].stars;
    }
    function getNFT_hero_stars(uint id) public view returns(uint stars){
        return heroTokenId_ToNFT[id].stars;
    }

}
