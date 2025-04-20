// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// 铭文ERC20代币实现合约
contract InscriptionToken is ERC20, Ownable {
    uint256 public immutable maxSupply;
    uint256 public immutable perMint;
    uint256 public immutable price;
    address public factory;
    uint256 public totalMinted;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxSupply_,
        uint256 perMint_,
        uint256 price_
    ) ERC20(name_, symbol_) {
        maxSupply = maxSupply_;
        perMint = perMint_;
        price = price_;
        factory = msg.sender;
        _transferOwnership(tx.origin); // 将所有权转移给部署者
    }

    // 铸造函数，只能由工厂合约调用
    function mint(address to) external payable {
        require(msg.sender == factory, "Only factory can mint");
        require(totalMinted + perMint <= maxSupply, "Exceeds max supply");
        require(msg.value >= price, "Insufficient payment");

        totalMinted += perMint;
        _mint(to, perMint);
    }
}

// 工厂合约
contract InscriptionFactory {
    using Clones for address;

    // 手续费比例 (1% = 100)
    uint256 public constant FEE_RATE = 50; // 0.5%
    address public feeReceiver;
    address public implementation;

    // 代币信息
    struct TokenInfo {
        string symbol;
        uint256 totalSupply;
        uint256 perMint;
        uint256 price;
        address owner;
    }

    mapping(address => TokenInfo) public tokenInfos;
    mapping(string => bool) public symbolExists;

    event TokenDeployed(
        address indexed token,
        string symbol,
        uint256 totalSupply,
        uint256 perMint,
        uint256 price,
        address owner
    );
    event TokenMinted(
        address indexed token,
        address indexed minter,
        uint256 amount,
        uint256 payment
    );

    constructor(address _feeReceiver) {
        feeReceiver = _feeReceiver;
        implementation = address(new InscriptionToken());
    }

    // 部署新的铭文代币
    function deployInscription(
        string memory symbol,
        uint256 totalSupply,
        uint256 perMint,
        uint256 price
    ) external {
        require(bytes(symbol).length > 0, "Symbol cannot be empty");
        require(!symbolExists[symbol], "Symbol already exists");
        require(totalSupply > 0, "Total supply must be positive");
        require(perMint > 0 && perMint <= totalSupply, "Invalid perMint");
        require(price > 0, "Price must be positive");

        // 使用固定名称 "Inscription Token"
        string memory name = string(abi.encodePacked(symbol, " Inscription Token"));
        
        // 使用最小代理部署新代币
        address token = implementation.clone();
        InscriptionToken(token).initialize(name, symbol, totalSupply, perMint, price);

        // 记录代币信息
        tokenInfos[token] = TokenInfo({
            symbol: symbol,
            totalSupply: totalSupply,
            perMint: perMint,
            price: price,
            owner: msg.sender
        });
        
        symbolExists[symbol] = true;

        emit TokenDeployed(token, symbol, totalSupply, perMint, price, msg.sender);
    }

    // 铸造铭文代币
    function mintInscription(address tokenAddr) external payable {
        TokenInfo memory info = tokenInfos[tokenAddr];
        require(info.owner != address(0), "Token not exists");

        // 计算手续费和用户收益
        uint256 fee = (msg.value * FEE_RATE) / 10000;
        uint256 ownerProfit = msg.value - fee;

        // 转账手续费和收益
        (bool feeSuccess, ) = feeReceiver.call{value: fee}("");
        (bool profitSuccess, ) = info.owner.call{value: ownerProfit}("");
        require(feeSuccess && profitSuccess, "Transfer failed");

        // 铸造代币
        InscriptionToken(tokenAddr).mint(msg.sender);

        emit TokenMinted(tokenAddr, msg.sender, info.perMint, msg.value);
    }

    // 获取代币信息
    function getTokenInfo(address tokenAddr) external view returns (TokenInfo memory) {
        return tokenInfos[tokenAddr];
    }
}

// 为最小代理模式添加初始化函数
abstract contract InitializableInscriptionToken is InscriptionToken {
    bool private _initialized;

    function initialize(
        string memory name_,
        string memory symbol_,
        uint256 maxSupply_,
        uint256 perMint_,
        uint256 price_
    ) public {
        require(!_initialized, "Already initialized");
        _initialized = true;
        InscriptionToken(name_, symbol_, maxSupply_, perMint_, price_);
    }
}
