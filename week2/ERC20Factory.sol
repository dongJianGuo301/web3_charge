// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract InscriptionToken is ERC20 {
    uint perMint;
    uint price;
    uint maxSupply;
    address factory;

    uint totalMinted;

    constructor(string memory _symbol,uint _maxSupply,uint _perMint,uint _price) ERC20("myInscriptionToken",_symbol) {
        maxSupply = _maxSupply;
        perMint = _perMint;
        price = _price;

        
        factory = msg.sender;
    }


    function  init(uint _maxSupply,uint _perMint,uint _price) public {
        maxSupply = _maxSupply;
        perMint = _perMint;
        price = _price;
    }

    function mint(address to) public checkMintPersion payable {
        // require((totalMinted + perMint <= maxSupply), "Exceeds max supply");
        // require (msg.value >= price,"Insufficient payment");
        // require ((factory == msg.sender),"Not the factory address");

        totalMinted += perMint;
        _mint(to, perMint);
    }

    modifier checkMintPersion {
        require((totalMinted + perMint <= maxSupply), "Exceeds max supply");
        require (msg.value >= price,"Insufficient payment");
        require ((factory == msg.sender),"Not the factory address");
        _;
    }

}

contract ERC20Factory {



    address internal factoryOwner;
    address internal templateToken;
    uint FEE_RATE = 100;//100 = 10%,运费比例10000

    mapping(address => TokenInfo) tokenInfoMapping;

    struct TokenInfo {
        string symbol;
        uint totalSupply;
        uint perMint;
        uint price;
        address owner;
        uint maxSupply;
    }

    constructor(address _templateToken ){
        factoryOwner = msg.sender;
        templateToken = _templateToken;
    }

    function deployInscription(string memory _symbol,uint _totalSupply,uint _perMint,uint _price) public returns (address){
        //通过最小代理合约方式创建合约
        address newTokenAddr = createClone(templateToken);
        InscriptionToken(newTokenAddr).init(_totalSupply,_perMint,_price);
        //记录已经创建的合约
        tokenInfoMapping[newTokenAddr] = TokenInfo({symbol: _symbol,totalSupply : _totalSupply ,perMint : _perMint,price: _price,owner: msg.sender,maxSupply : 0});

        return newTokenAddr;
    }

    function createClone(address prototype) internal returns (address proxy) {
        bytes20 targetBytes = bytes20(prototype);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            proxy := create(0, clone, 0x37)
        }
        return proxy;
    }

    


}
