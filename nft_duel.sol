// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



// Helper we wrote to encode in Base64
import "./Base64.sol";
// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Dark_Girls is ERC1155{
    
    //CONSTANTS
    using Counters for Counters.Counter;    
    Counters.Counter private _heroesTokenId_Counter;
    Counters.Counter private _itemTokenId_Counter;

    //NFT associated with a heroTokenId_
    mapping(uint256 => NFT) public heroTokenId_ToNFT;
    mapping(uint256 => NFT) public itemTokenId_ToNFT;

    mapping(uint => address) public heroTokenId_ToOwner;
    mapping(uint => address) public itemTokenId_ToOwner;

    mapping(address => uint[]) public NFTsAtAddress;

    modifier isNotStaked(uint heroTokenId_){
        require(heroesTokenId_ToNFT[heroesTokenId_].staked == false);
        _;
    }
    modifier isStaked(uint heroTokenId_){
        require(heroesTokenId_ToNFT[heroesTokenId_].staked == true);
        _;
    }
    modifier isNftOwner(uint heroTokenId_){
        require(heroesTokenId_ToOwner[heroesTokenId_] == msg.sender);
        _;
    }

    struct NFT{
        string name;
        string imageURI;  
        uint stars;
        bool staked;
    }

    function stake(uint heroTokenId_) public isNotStaked(heroesTokenId_) isNftOwner(heroesTokenId_){
        heroTokenId_ToNFT[heroesTokenId_].staked = true;
        heroTokenId_ToNFT[heroesTokenId_].stars += 1;
    }

    function unstake(uint heroTokenId_) public isStaked(heroesTokenId_) isNftOwner(heroesTokenId_){
        heroTokenId_ToNFT[heroesTokenId_].staked = false;
        heroTokenId_ToNFT[heroesTokenId_].stars += 1;
    }
    //CREATION
    //create decks / boosters
    //nft on chain
    NFT[] yugi_deck;
    
    function create() internal{
      yugi_deck.push(NFT("Dark_Girl","img1",6,false));
      yugi_deck.push(NFT("Dark_Girl","img1",6,false));
      yugi_deck.push(NFT("Dark_Girl","img1",6,false));
      yugi_deck.push(NFT("Dark_Girl","img1",6,false));
      yugi_deck.push(NFT("Dark_Girl","img1",6,false));
      yugi_deck.push(NFT("Dark_Girl","img1",6,false));
      yugi_deck.push(NFT("Dark_Girl","img1",6,false));
      yugi_deck.push(NFT("Dark_Girl","img1",6,false));
      yugi_deck.push(NFT("Dark_Girl","img1",6,false));
      yugi_deck.push(NFT("Dark_Girl","img1",6,false));
    }


    constructor() public ERC1155("https://raw.githubusercontent.com/mcruzvas/react_web3/main/metadata/{id}.json") {
        create();

        _heroesTokenId_Counter.increment();
        _itemTokenId_Counter.increment();

        //no of NFTs in deployed in the blockchain
    }

    //MINTERS
    //function to use random Number TODO
    function finishMint(uint i) public {
        uint heroTokenId_ = _heroesTokenId_Counter.current();
        
        _mint(msg.sender, heroTokenId_,1,"");

        heroTokenId_ToNFT[heroesTokenId_] = yugi_deck[i];
        NFTsAtAddress[msg.sender].push(heroesTokenId_);
        heroTokenId_ToOwner[heroesTokenId_] = msg.sender;
        _heroesTokenId_Counter.increment();
    }
    function itemMint() public{
        uint itemTokenId_ = _itemTokenId_Counter.current();
    }

    //GETS
    function nftAccount() public view returns(uint[] memory arr){
        return NFTsAtAddress[msg.sender];
    }
    function getNFT(uint heroTokenId_) public view returns(string memory name){
        return heroTokenId_ToNFT[heroesTokenId_].name;
    }
    function getNFT(uint itemTokenId_) public view returns(string memory name){
        return itemTokenId_ToNFT[itemTokenId_].name;
    }

}
