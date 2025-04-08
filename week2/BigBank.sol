// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBank {
    function getBalance() external  view returns(uint);
    function setAdmin() external;
    function getTop3Addr(uint index) external view returns (address);
    function withdraw(address payable requestAddr) external payable;
}

contract Bank {
    mapping(address => uint) balances;
    address[3] top3;
    address admin;

    constructor(){
        admin = msg.sender;
    }

    function feed() public payable virtual  { 
        balances[msg.sender] += msg.value; // transfer ether
        // top3[0] = msg.sender;

        for(uint i=0;i<3;i++){
            address currentAddr = top3[i];
            if(currentAddr == 0x0000000000000000000000000000000000000000){
                top3[i] = msg.sender;
                break;
            }
            uint balance = balances[currentAddr];
            if(balance > balances[msg.sender]){
                continue;
            }else{
                for(uint j=2;j>i;j--){
                    top3[j] = top3[j-1];
                }
                top3[i] = msg.sender;
                break;
            }
            
        }
     }

    function getBalance() external view returns(uint) {
       return balances[msg.sender];
    }

    function setAdmin(address _address) external {
        require(admin == msg.sender,"only admin can do this");
        admin = _address;
    }

    function getTop3Addr(uint index) external view returns (address){
        require(index<=2,"invalid index");
        return top3[index];
    }


    function withdraw(address payable requestAddr) external payable olnyAdmin(requestAddr) {
        address contractAddr = address(this);
        requestAddr.transfer(contractAddr.balance);
    }

    modifier olnyAdmin(address payable requestAddr){
        require(requestAddr == admin,"only admin can do this");
        _;
    }
}

contract BigBank is Bank {
   function feed() public payable override  checkTransferAmount {
        super.feed();
    }

    modifier checkTransferAmount(){
        require(msg.value > 0.001 ether,"minimum transfer amount is 0.001 ether");
        _;
    }
}


contract Admin {
    address internal owner;

    constructor(){
        owner = msg.sender;
    }

    function setOwner(address _address) public {
        require(owner == msg.sender,"only admin can do this");
        owner = _address;
    }

    function adminWithdraw(IBank bank) public {
        bank.withdraw(payable(msg.sender)); 
    }
}
