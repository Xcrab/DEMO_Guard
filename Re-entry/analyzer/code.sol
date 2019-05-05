pragma solidity ^0.4.23;
contract test{
    mapping (address => uint256) public tokenbalance;

    function test1() public payable {
        if(msg.value > 0){
            tokenbalance[msg.sender] += msg.value;
        }
    }


    function test3(uint256 value) public{
        if (tokenbalance[msg.sender] > value) {
            require(msg.sender.call.value(value)());
            tokenbalance[msg.sender] -= value;
        }
    }
}