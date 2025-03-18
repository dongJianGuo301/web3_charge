// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Bank {
  mapping(address => uint) balances;
  address[3] top3;
  address admin;

  constructor(){
    admin = msg.sender;
  }

  receive() external payable { 
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

  function getBalance() public view returns(uint) {
   return balances[msg.sender];
  }

  function setAdmin() public {
    require(admin == msg.sender,"only admin can do this");
    admin = msg.sender;
  }

  function getTop3Addr(uint index) public view returns (address){
    require(index<=2,"invalid index");
    return top3[index];
  }

  function withdraw(address payable requestAddr) public payable olnyAdmin(requestAddr) {
    address contractAddr = address(this);
    requestAddr.transfer(contractAddr.balance);
  }

  modifier olnyAdmin(address payable requestAddr){
    require(requestAddr == admin,"only admin can do this");
    _;
  }
}
