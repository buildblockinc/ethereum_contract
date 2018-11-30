pragma solidity ^0.4.23;

import "../openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";


contract BuildToken is MintableToken {

    address public owner;
    string public name = 'BB from Build Block Inc.';
    string public facts = '1. Currency of BB - 1BB = 1 Korean Won \n2. The role of the contract owner is similar to a central bank.';
    string public symbol = 'BuildBlock (BB) Coin';
    uint8 public decimals = 2;
    uint public INITIAL_SUPPLY = 100000000000000000;

    // keeps track of those contract that can call this contract
    mapping (address => bool) valid_caller_contracts;

    constructor() public {
        owner = msg.sender;
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }

    // This must be called for every deployed ProjectToken contracts
    function registerValidContract(address project_contract) public {
        require(msg.sender == owner);
        valid_caller_contracts[project_contract] = true;
    }

    function transferByOwner(address _from, address _to, uint256 _value) public returns (bool success) {
        require(msg.sender == owner);
        require(_to != address(0));
        require(_from != _to);
        require(_value <= balances[_from]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] =  balances[_to].add(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    function transferByOwnerRemote(address _from, address _to, uint256 _value) external returns (bool success) {
        // The following two checks allow us to make this function only be called from our ProjectToken contracts
        require(tx.origin == owner);
        require(valid_caller_contracts[msg.sender]);
        require(_to != address(0));
        require(_from != _to);
        require(_value <= balances[_from]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] =  balances[_to].add(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

}
