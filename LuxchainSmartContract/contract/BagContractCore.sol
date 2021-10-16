pragma solidity >=0.4.21 <0.7.0;
/* import "./erc721.sol"; */
/* import "./BagBase.sol"; */

contract ERC721 {
  function totalSupply() public view returns (uint256 total);
  function balanceOf(address _owner) public view returns (uint balance);
  function ownerOf(uint256 _tokenId) external view returns (address owner);
  function transfer(address _to, uint256 _tokenId) external;


}

contract BagBase {


  uint public BagIndex;

  
  string[] lst;
  struct Bag {
    uint id;  // 商品的ID 
    
    string goods; 
    
    uint price;  // 商品的价格
    
    string condition;  // 商品的等级
    
    string desc;  // 商品的详情描述
    
    string image2;  // 比对图片
    address seller; // 卖家地址
   
    string userinfo;
    
  }

  mapping (uint256 => address) bagIndexToOwner;
  mapping (address => uint256) ownershipTokenCount;
  mapping(address => mapping(uint256 => Bag)) bagInfo;
    
  constructor() public {
    BagIndex = 0;
  } 

  Bag[] bags;

  function _transfer(address _from, address _to, uint256 _tokenId) internal {
    if (_from != address(0)) {
      ownershipTokenCount[_from]--;
    }
    ownershipTokenCount[_to]++;
    bagIndexToOwner[_tokenId] = _to;
    
  }
  
  
  function _createBag(string memory _goods, 
    uint _price, string memory _image2, address _seller, string memory _condition, string memory _desc, string memory _userinfo
    ) internal returns (uint) {
      require(_seller != address(0));
      BagIndex += 1;
      
      Bag memory _bag = Bag({
        id: BagIndex,
        goods: _goods,
        price: _price,
        image2: _image2,
        seller: _seller,
        condition: _condition,
        desc: _desc,
        userinfo: _userinfo
        });
        
      bagInfo[msg.sender][BagIndex] = _bag;
      bagIndexToOwner[BagIndex] = msg.sender;
      uint newBagId = bags.push(_bag) - 1;
      _transfer(address(0), _seller, newBagId);

      return newBagId;
    }
    
    function _updateBag(uint _id, string memory _goods, 
        uint _price, string memory _image2, address _seller, string memory _condition, string memory _desc, string memory _userinfo
        ) internal {
        
        Bag memory _bag = Bag({
            id: _id,
            
            goods: _goods,
            
            price: _price,
            image2: _image2,
           
            seller: _seller,
           
            condition: _condition,
            desc: _desc,
            userinfo: _userinfo
            
        });
        
      bagInfo[msg.sender][BagIndex] = _bag;
      bagIndexToOwner[BagIndex] = msg.sender;
    }
}


contract BagCore is BagBase, ERC721 {
  string public constant name = "LuxFi";
  string public constant symbol = "LXF";
  
  event Transfer(address indexed from, address to, uint256 indexed tokenId);
  event AddBagTransfer(uint indexed bagid, string goods, uint price, string image, address indexed seller,
        string bagcondition, string desc, string userinfo);
  event updateBagTransfer(uint indexed bagid, string goods, uint price, string image, address indexed seller,
        string bagcondition, string desc, string userinfo);
    
  function addBag(string memory _goods, uint _price, string memory _image2, address _seller, 
    string memory _bagcondition, string memory _desc, string memory _userinfo
    ) public returns (uint) {
      _createBag(_goods, _price, _image2, _seller, _bagcondition, _desc, _userinfo);
      uint bagid = BagIndex;
      emit AddBagTransfer(bagid, _goods, _price, _image2, _seller, _bagcondition, _desc, _userinfo);
    
      return bagid;
  }
  
  function updateBag(uint _id, string memory _goods, 
        uint _price, string memory _image2, address _seller, string memory _condition, string memory _desc, string memory _userinfo
        ) public {
            require(_owns(msg.sender, _id));
            _updateBag(_id, _goods, _price, _image2, _seller, _condition, _desc, _userinfo);
            emit updateBagTransfer(_id, _goods, _price, _image2, _seller, _condition, _desc, _userinfo);
        }
  
  function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
    return bagIndexToOwner[_tokenId] == _claimant;
  }

  function balanceOf(address _owner) public view returns (uint256 count) {
    return ownershipTokenCount[_owner];
  }

  function transfer(address _to, uint256 _tokenId) external {
    require(_to != address(0));
    require(_to != address(this));
    require(_owns(msg.sender, _tokenId));
    _transfer(msg.sender, _to, _tokenId);
    emit Transfer(msg.sender, _to, _tokenId);
  }

  function totalSupply() public view returns (uint) {
    return bags.length;
  }
  
   function ownerOf(uint256 _tokenId) external view returns (address owner) {
        owner = bagIndexToOwner[_tokenId];

        require(owner != address(0));
        return owner;
    }
  
  function tokensOfOwner(address _owner) external view returns(uint256[] memory owerTokens) {
    uint256 tokenCount = balanceOf(_owner);
    if (tokenCount == 0) {
      return new uint256[](0);
    } else {
      uint256[] memory result = new uint256[](tokenCount);
      uint256 totalBags = totalSupply();
      uint256 resultIndex = 0;
      uint256 bagId;
      for (bagId=1; bagId<= totalBags; bagId++){
        if (bagIndexToOwner[bagId] == _owner){
          result[resultIndex] = bagId;
          resultIndex++;
        }
      }
      return result;
    }
  }

  // 查看链上的商品的信息
  function getBag(uint _productId) view public returns (uint,
      string memory, uint, string memory, address , string memory, string memory, string memory){
        Bag storage product = bagInfo[bagIndexToOwner[_productId]][_productId];
        return (product.id, product.goods, product.price, product.image2, product.seller,
         product.condition, product.desc, product.userinfo);
      }
}
