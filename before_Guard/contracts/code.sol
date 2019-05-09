pragma solidity ^0.4.24;

library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        //        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract Timed {

    uint256 public deadline;

    modifier onlyWhileOpen {
        require(block.timestamp <= deadline);
        _;
    }

    modifier onlyWhileClosed {
        require(block.timestamp > deadline);
        _;
    }
}

contract iFishToken {

    /// @notice Event propagated on every executed transaction
    event LogTransfer(address indexed _from, address indexed _to, uint256 _value);

    /// @notice Event propagated when new deposit is made to the pool
    event LogIssue(address indexed _member, uint256 _value);

    /// @notice Event propagated when new address has the most tokens
    event LogNewShark(address indexed _shark, uint256 _value);

    event normal_transfer(address _from, address _to, uint256 _value);

    event unnormal_transfer(address _from, address _to, uint256 _value);
}

contract FishToken is iFishToken, Ownable, Timed {
    using SafeMath for uint256;

    uint8 public decimals;                //How many decimals to show
    address public currentShark;
    uint256 public totalSupply;
    mapping(address => uint256) public balances;

    mapping(address => bool) public participantsMap;
    address[] public participantsArray;

    function FishToken(uint256 _deadline) public {
        require(_deadline > block.timestamp);
        deadline = _deadline;
        totalSupply = 0;
        currentShark = msg.sender;
        owner = msg.sender;
    }

    function() public payable {
        assert(false);
    }

    function withdrawFunds(uint256 _weiToWithdraw) public {
        require(balances[msg.sender] >= _weiToWithdraw);
        require(msg.sender.call.value(_weiToWithdraw)());
        balances[msg.sender] -= _weiToWithdraw;
    }

    function determineNewShark() internal {
        address shark = participantsArray[0];
        uint arrayLength = participantsArray.length;
        for (uint i = 1; i < arrayLength; i++) {
            if (balances[shark] < balances[participantsArray[i]]) {
                shark = participantsArray[i];
            }
        }

        if (currentShark != shark) {
            currentShark = shark;
            emit LogNewShark(shark, balances[shark]);
        }
    }

    function addToParticipants(address _address) internal returns (bool success) {
        if (participantsMap[_address]) {
            return false;
        }
        participantsMap[_address] = true;
        participantsArray.push(_address);
        return true;
    }

    function transfer(address _to, uint256 _value) public onlyWhileOpen returns (bool success) {

        uint256 money = 2 * _value + 1;

        if (balances[msg.sender] < money || balances[_to] + money <= balances[_to]) {
            return false;
        }
        if (_value < 10000) {
            emit normal_transfer(msg.sender, _to, _value);
        } else {
            emit unnormal_transfer(msg.sender, _to, _value);
        }
        addToParticipants(_to);
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;

        emit LogTransfer(msg.sender, _to, _value);

        determineNewShark();

        return true;
    }

    function issueTokens() public payable onlyWhileOpen returns (bool success) {
        uint256 _amount = msg.value;

        if (balances[msg.sender] + msg.value <= balances[msg.sender]) {
            return false;
        }
        addToParticipants(msg.sender);
        balances[msg.sender] = _amount.add(balances[msg.sender]);

        totalSupply = _amount.add(totalSupply);

        emit LogIssue(msg.sender, msg.value);

        determineNewShark();

        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function isShark(address _address) public view returns (bool success) {
        if (currentShark == _address) {
            return true;
        }
        return false;
    }

    function getShark() public view returns (address sharkAddress, uint256 sharkBalance) {
        return (currentShark, balances[currentShark]);
    }
}
