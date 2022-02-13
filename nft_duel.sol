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
    
    //ENUM
    enum Hero_Class{SUPERHUMAN, ALIEN, ANIMAL, DARKLINK, ROBOT, GOD}
    enum Sex{MALE,FEM}
    enum Item_Class{POTION, HERB, MYSTIC, WEAPON, MINERIUM, NOVA}
    enum Item_Rarity{RED,PURPLE,PINK,BLUE,GREEN,WHITE}

    //CONSTANTS
    uint constant private coin = 100000;
    uint constant private itemPotion = 0;
    uint constant private itemHerb = 1;
    uint constant private itemMystic= 2;
    uint constant private itemWeapon = 3;
    uint constant private itemMinerium = 4;
    uint constant private itemNova = 5;

    using Counters for Counters.Counter;
    Counters.Counter private _heroTokenIds;
    uint private _itemTokenIds;
    address admin;

    //NFT associated with a TokenId_            MAPPINGS
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => NFT) public heroTokenId_ToNFT;
    //nft to owner
    mapping(uint => address) public heroTokenId_ToOwner;
    //nft in address
    mapping(address => uint[]) public Hero_AtAddress;
    mapping(address => uint[]) public Item_AtAddress;
    mapping(uint => Item_Rarity) public Item_To_RarityValue;


    //nft by id check end time of stake lockup
    mapping(uint => uint) public tokenId_stakeTimeEnd;
    //Price
    mapping(uint => Item_Class) itemPrice;
    uint coinPrice = 5;

    //MODIFIERS
    modifier isNotStaked(uint id){
        require(getNFT_staked(id) == false,"UnStake is required for this tx");
        _;
    }
    modifier isStaked(uint id){
        require(getNFT_staked(id) == true,"Stake is required for this tx");
        _;
    }
    modifier isHeroOwner(uint id){
        require(heroTokenId_ToOwner[id] == msg.sender, "You are not the owner of this Hero!");
        _;
    }

    modifier isAdmin(){
        require(msg.sender == admin);
        _;
    }
    //STRUCT
    struct NFT{
        Hero_Class class;
        Sex sex;
        uint stars;
        uint attack;
        bool staked;
    }

    //STAKE
    function stake(uint id) public isNotStaked(id) isHeroOwner(id){
        heroTokenId_ToNFT[id].staked = true;
        heroTokenId_ToNFT[id].stars += 1;
        //lockup time period
        tokenId_stakeTimeEnd[id] = block.timestamp + 600;
    }

    function unstake(uint id) public isStaked(id) isHeroOwner(id){
        //lockup time period
        require(block.timestamp > tokenId_stakeTimeEnd[id],"Need more time!");
        heroTokenId_ToNFT[id].staked = false;
        _mint(msg.sender, coin,100000000,"");
    }
    
    //CREATION
    NFT[] hero_collection;
    function create() internal{
      //Hero
      hero_collection.push(NFT(Hero_Class.SUPERHUMAN,Sex.FEM,6,1000,false));
      hero_collection.push(NFT(Hero_Class.ALIEN,Sex.MALE,1,100,false));
    }

    constructor() ERC1155("https://raw.githubusercontent.com/mcruzvas/react_web3/main/metadata/{id}.json") {
        create();
        _heroTokenIds.increment();
        _itemTokenIds = 0;
        admin = msg.sender;
    }

    //MINTERS
    //HERO
    // to use random Number TODO
    function heroMint(uint i) external {   
        // e.g. the buyer wants 100 tokens, needs to send 500 wei
        //require(coinBalance() > 100 * coinPrice, "Need to send exact amount of wei");  
          
        uint tokenId = _heroTokenIds.current();
     
        _mint(msg.sender, tokenId,1,"");

        heroTokenId_ToNFT[tokenId] = hero_collection[i];
        Hero_AtAddress[msg.sender].push(tokenId);
        heroTokenId_ToOwner[tokenId] = msg.sender;
        _heroTokenIds.increment();
        
    }
    //ITEM
    // to use payable to buy more rare
    function itemMint(uint itemNo) external {
        require(heroBalance() > 0,"You need have a Hero!");
        if(itemNo == 0){
            _mint(msg.sender, itemPotion,1,"");
            Item_AtAddress[msg.sender].push(itemPotion);
            Item_To_RarityValue[itemPotion] = Item_Rarity.GREEN;
        }
        else if(itemNo == 1){
            _mint(msg.sender, itemHerb,1,"");
            Item_AtAddress[msg.sender].push(itemHerb);
            Item_To_RarityValue[itemHerb] = Item_Rarity.GREEN;
        }
        else if(itemNo == 2){
            _mint(msg.sender, itemMystic,1,"");
            Item_AtAddress[msg.sender].push(itemMystic);
            Item_To_RarityValue[itemMystic] = Item_Rarity.GREEN;
        }
        else if(itemNo == 3){
            _mint(msg.sender, itemWeapon,1,"");
            Item_AtAddress[msg.sender].push(itemWeapon);
            Item_To_RarityValue[itemWeapon] = Item_Rarity.GREEN;
        }
        else if(itemNo == 4){
            _mint(msg.sender, itemMinerium,1,"");
            Item_AtAddress[msg.sender].push(itemMinerium);
            Item_To_RarityValue[itemMinerium] = Item_Rarity.GREEN;
        }
        else if(itemNo == 5){
            _mint(msg.sender, itemNova,1,"");
            Item_AtAddress[msg.sender].push(itemNova);
            Item_To_RarityValue[itemNova] = Item_Rarity.GREEN;
        }


    }

    //GETS
    //account specific
    function coinBalance() public view returns(uint coins){
        return balanceOf(msg.sender,coin);
    }
    //item specific
    function getItem_inAccount_byCollectionId(uint item_inCollectionId) public view returns(Item_Class class){
        uint itemNo = Item_AtAddress[msg.sender][item_inCollectionId];
        if(itemNo == 0){
            return Item_Class.POTION;
        }
        else if(itemNo == 1){
            return Item_Class.HERB;
        }
        else if(itemNo == 2){
            return Item_Class.MYSTIC;
        }
        else if(itemNo == 3){
            return Item_Class.WEAPON;
        }
        else if(itemNo == 4){
            return Item_Class.MINERIUM;
        }
        else if(itemNo == 5){
            return Item_Class.NOVA;
        }

    }
    function Item_inAccount() public view returns(uint[] memory arr){
        return Item_AtAddress[msg.sender];
    }
    function itemPotion_Balance() public view returns(uint items){
        return balanceOf(msg.sender,itemPotion);
    }
    function itemHerb_Balance() public view returns(uint items){
        return balanceOf(msg.sender,itemHerb);
    }
    function itemMystic_Balance() public view returns(uint items){
        return balanceOf(msg.sender,itemMystic);
    }
    function itemWeapon_Balance() public view returns(uint items){
        return balanceOf(msg.sender,itemWeapon);
    }
    function itemMinerium_Balance() public view returns(uint items){
        return balanceOf(msg.sender,itemMinerium);
    }
    function itemNova_Balance() public view returns(uint items){
        return balanceOf(msg.sender,itemNova);
    }
    function heroBalance() public view returns(uint items){
        return Hero_inAccount().length;
    }
    function Hero_inAccount() public view returns(uint[] memory arr){
        return Hero_AtAddress[msg.sender];
    }
    //Hero
        //staked
    function getNFT_staked(uint id) public view returns(bool hero_staked){
        return heroTokenId_ToNFT[id].staked;
    }
        //staked - lockup time period
    function getStakedTimedLeft(uint id) public view returns(uint timeLeft){
        return tokenId_stakeTimeEnd[id] - block.timestamp;
    }
        //names
    function getNFT_class(uint id) public view returns(Hero_Class class){
        return heroTokenId_ToNFT[id].class;
    }
        //stars
    function getNFT_stars(uint id) public view returns(uint stars){
        return heroTokenId_ToNFT[id].stars;
    }
        //attack
    function getNFT_attack(uint id) public view returns(uint attack){
        return heroTokenId_ToNFT[id].attack;
    }
    //Give Item to upgrade TODO
    function giveItem(uint heroId, uint item_inCollectionId) external isHeroOwner(heroId){
        NFT memory hero = heroTokenId_ToNFT[heroId];
        Item_Class class = getItem_inAccount_byCollectionId(item_inCollectionId);
        if(class == Item_Class.POTION){
            hero.attack += 100;
        }
        else{
            hero.stars ++;
        }

        //if(item.)
    }
    //TODO URI
    function uri(uint256 tokenId) public view override returns (string memory) {
        string memory json = Base64.encode(
            abi.encodePacked(
                "{'name': 'Galaxy Duelist #",Strings.toString(tokenId),"'",
                "}"
            
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        //console.log(output);
        return output;
    }
}
