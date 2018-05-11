pragma solidity ^0.4.23;

import "../openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";

contract ZipToken is StandardToken {

    string public name = 'ZIP Token from Z-BSI';
    string public symbol = 'ZIP';
    uint8 public decimals = 18;
    uint public INITIAL_SUPPLY = 1000000;

    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }

}
