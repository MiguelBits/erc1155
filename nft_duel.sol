// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Helper we wrote to encode in Base64
import "./Base64.sol";
// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
contract Galaxy_heroes is ERC1155, ReentrancyGuard{

    using SafeMath for uint;

    //Events
    event hasStakedChanged(bool status, uint tokenId);
    event new_battle(uint sender, uint opponent);

    //ENUM
    enum GameOutcome {
        Fighting,
        Draw,
        Win,
        Lose
    }
    enum Hero_Class{ROBOT, GOD, SUPERHUMAN, ALIEN, ANIMAL, DARKLINK}
    
    //CONSTANTS
    uint constant private coin = 100000;

    NFT[] public hero_collection;
    using Counters for Counters.Counter;
    Counters.Counter private _heroTokenIds;
    Counters.Counter private _gameIds;
    address private admin;

    //NFT associated with a TokenId_            MAPPINGS
    mapping(uint => Counters.Counter) heroClass_amountMinted;
    mapping(uint => uint) tokenId_classId;
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => NFT) public heroTokenId_ToNFT;
    //nft to owner
    mapping(uint => address) public heroTokenId_ToOwner;
    //nft in address
    mapping(address => uint[]) public Hero_AtAddress;
    mapping(address => uint[]) public Item_AtAddress;
    //battle mappings
    uint[] stakedIDs;
    mapping (uint => Game_Duel) public games_by_id;

    //nft by id check end time of stake lockup
    mapping(uint => uint) public tokenId_stakeTimeEnd;
    //Price

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
        uint stars;
        uint attack;
        bool staked;
        //element;
        //sex;
    }
    
    struct Game_Duel {
        uint playerOne;
        uint playerTwo;
        GameOutcome outcome;
    }
    //STAKE
    function stake(uint id) public isNotStaked(id) isHeroOwner(id){
        heroTokenId_ToNFT[id].staked = true;
        heroTokenId_ToNFT[id].stars += 1;
        //lockup time period
        tokenId_stakeTimeEnd[id] = block.timestamp + 600;
        stakedIDs.push(id);
        
        emit hasStakedChanged(true,id);
    }

    function unstake(uint id) public isStaked(id) isHeroOwner(id){
        //lockup time period
        require(block.timestamp > tokenId_stakeTimeEnd[id],"Need more time!");
        heroTokenId_ToNFT[id].staked = false;
        _mint(msg.sender, coin,100000000,"");
        for(uint i = 0; i>stakedIDs.length-1;i++){
            if(stakedIDs[i] == id){
                delete stakedIDs[i];
            }
        }
        emit hasStakedChanged(false,id);
    }
    
    //CREATION
    constructor() ERC1155("https://raw.githubusercontent.com/mcruzvas/erc1155/main/metadata/") {
        _heroTokenIds.increment();
        admin = msg.sender;
        _gameIds.increment();
    }

    //MINTERS
    //HERO
    function heroMint(uint class) external{
        require(class == 1 || class == 2 || class == 3 || class == 4 || class == 5 || class == 6);

        //get counter
        uint tokenId = _heroTokenIds.current();
        //mint gen ID
        _mint(msg.sender, tokenId,1, "");
        
        //new hero with class id logic
        uint class_id;
        NFT memory new_hero;
        if(class == 1){
            class_id = heroClass_amountMinted[class].current();
            new_hero = NFT(Hero_Class.ROBOT,1,500,false);
        }
        else if(class == 2){
            class_id = heroClass_amountMinted[class].current();
            new_hero = NFT(Hero_Class.GOD,1,500,false);
        }
        else if(class == 3){
            class_id = heroClass_amountMinted[class].current();
            new_hero = NFT(Hero_Class.SUPERHUMAN,1,500,false);
        }
        else if(class == 4){
            class_id = heroClass_amountMinted[class].current();
            new_hero = NFT(Hero_Class.ALIEN,1,500,false);
        }
        else if(class == 5){
            class_id = heroClass_amountMinted[class].current();
            new_hero = NFT(Hero_Class.ANIMAL,1,500,false);
        }
        else if(class == 6){
            class_id = heroClass_amountMinted[class].current();
            new_hero = NFT(Hero_Class.DARKLINK,1,500,false);
        }
        //update mappings
        hero_collection.push(new_hero);
        heroTokenId_ToNFT[tokenId] = new_hero;
        Hero_AtAddress[msg.sender].push(tokenId);
        heroTokenId_ToOwner[tokenId] = msg.sender;
        _heroTokenIds.increment();
        
        tokenId_classId[tokenId] = class_id;

        heroClass_amountMinted[class].increment();
    }

    //GETS
    //amounts available
    function getPopulation(uint class) public view returns(uint256 pop){
        require(class == 1 || class == 2 || class == 3 || class == 4 || class == 5 || class == 6);
        return heroClass_amountMinted[class].current();
    }
    //account specific
    function ownerOf(uint id) public view returns (address){
        return heroTokenId_ToOwner[id];
    }
    //coin
    function coinBalance() public view returns(uint coins){
        return balanceOf(msg.sender,coin);
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
        if(tokenId_stakeTimeEnd[id] > block.timestamp){
            return tokenId_stakeTimeEnd[id] - block.timestamp;
        }
        else{
            return 0;
        }
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
        //Get all staked
    function getStakedPopulation() public view returns(uint [] memory pop){
        return stakedIDs;
    }
    //Give Item to upgrade TODO
    function giveItem(uint heroId, uint item_inCollectionId) external view isHeroOwner(heroId){
        
    }

    function uri(uint256 id) public view virtual override returns (string memory) {
        string memory classId = Strings.toString(tokenId_classId[id]);

        if(getNFT_class(id) == Hero_Class.DARKLINK){
            return string(abi.encodePacked("https://raw.githubusercontent.com/mcruzvas/erc1155/main/metadata/","Darklink/","6",classId,".json"));
        }
        else if(getNFT_class(id) == Hero_Class.ANIMAL){
            return string(abi.encodePacked("https://raw.githubusercontent.com/mcruzvas/erc1155/main/metadata/","Animal/","5",classId,".json"));
        }
        else if(getNFT_class(id) == Hero_Class.ALIEN){
            return string(abi.encodePacked("https://raw.githubusercontent.com/mcruzvas/erc1155/main/metadata/","Alien/","4",classId,".json"));
        }
        else if(getNFT_class(id) == Hero_Class.SUPERHUMAN){
            return string(abi.encodePacked("https://raw.githubusercontent.com/mcruzvas/erc1155/main/metadata/","Superhuman/","3",classId,".json"));
        }
        else if(getNFT_class(id) == Hero_Class.GOD){
            return string(abi.encodePacked("https://raw.githubusercontent.com/mcruzvas/erc1155/main/metadata/","God/","2",classId,".json"));
        }
        else if(getNFT_class(id) == Hero_Class.ROBOT){
            return string(abi.encodePacked("https://raw.githubusercontent.com/mcruzvas/erc1155/main/metadata/","Robot/","1",classId,".json"));
        }
        else{
            return string("https://i.pinimg.com/originals/fd/0c/b9/fd0cb97ac9aaa1341195b1c4ab58fb6f.png");
        }
    }

    function Duel(uint tokenId, uint enemyId) public isStaked(tokenId) returns(Game_Duel memory){
        require(ownerOf(tokenId) != ownerOf(enemyId));

        //game
        GameOutcome status = GameOutcome.Fighting;
        Game_Duel memory duel = Game_Duel(tokenId,enemyId,status);

        //attack
        uint attackPoints = 3;

        uint starsPlayer = getNFT_stars(tokenId);
        uint starsEnemy = getNFT_stars(enemyId);

        Hero_Class playerClass = getNFT_class(tokenId);
        Hero_Class enemyClass = getNFT_class(enemyId);

        uint attackPlayer = getNFT_attack(tokenId);
        uint attackEnemy = getNFT_attack(enemyId);

        emit new_battle(tokenId,enemyId);

        //decision
        if(starsPlayer > starsEnemy){
            attackPoints += 1;
        }
        else if(starsPlayer < starsEnemy){
            attackPoints -= 1;
        }

        if(playerClass == Hero_Class.DARKLINK){
            if(enemyClass == Hero_Class.ANIMAL){
                attackPoints -= 1;
            }
            else if(enemyClass == Hero_Class.ROBOT){
                attackPoints += 1;
            }
        }
        else if(playerClass == Hero_Class.ANIMAL){
            if(enemyClass == Hero_Class.ALIEN){
                attackPoints -= 1;
            }
            else if(enemyClass == Hero_Class.DARKLINK){
                attackPoints += 1;
            }
        }
        else if(playerClass == Hero_Class.ALIEN){
            if(enemyClass == Hero_Class.SUPERHUMAN){
                attackPoints -= 1;
            }
            else if(enemyClass == Hero_Class.ANIMAL){
                attackPoints += 1;
            }
        }
        else if(playerClass == Hero_Class.SUPERHUMAN){
            if(enemyClass == Hero_Class.GOD){
                attackPoints -= 1;
            }
            else if(enemyClass == Hero_Class.ALIEN){
                attackPoints += 1;
            }
        }
        else if(playerClass == Hero_Class.GOD){
            if(enemyClass == Hero_Class.ROBOT){
                attackPoints -= 1;
            }
            else if(enemyClass == Hero_Class.SUPERHUMAN){
                attackPoints += 1;
            }
        }
        else if(playerClass == Hero_Class.ROBOT){
            if(enemyClass == Hero_Class.DARKLINK){
                attackPoints -= 1;
            }
            else if(enemyClass == Hero_Class.GOD){
                attackPoints += 1;
            }
        }
        // outcome
        if(attackPlayer > 2){
            uint new_attackPlayer = attackPlayer + (attackPoints*100);
            if(new_attackPlayer > attackEnemy){
                status = GameOutcome.Win;
            }
            else if(new_attackPlayer < attackEnemy){
                status = GameOutcome.Lose;
            }
            else{
                status = GameOutcome.Draw;
            }
        }
        else if(attackPlayer == 2){
            if(attackPlayer > attackEnemy){
                status = GameOutcome.Win;
            }
            else if(attackPlayer < attackEnemy){
                status = GameOutcome.Lose;
            }
            else{
                status = GameOutcome.Draw;
            }
        }
        else{
            status = GameOutcome.Lose;
        }
        //store result
        uint current = _gameIds.current();
        _gameIds.increment();
        duel.outcome = status;
        games_by_id[current] = duel;

        return duel;
    }
}
