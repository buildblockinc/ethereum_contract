pragma solidity ^0.4.23;

import "../openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "./ZipToken.sol";

contract ProjectToken is StandardToken {

    ZipToken public token;
    string public name;
    string public symbol;
    uint8 public decimals = 0;
    mapping (address => uint) public coinCashRates;

    mapping (address => uint) public indices;
    address[] public addresses;

    constructor(address _tokenAddress, uint INITIAL_SUPPLY, string _name, string _symbol) public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        addresses.push(msg.sender);
        token = ZipToken(_tokenAddress);
        name = _name;
        symbol = _symbol;
    }

    function payInterestsInToken(uint amount) public {
        require(token.allowance(msg.sender, this) >= amount);
        for (uint i=1; i<addresses.length; i++) {
            token.transferFrom(msg.sender, addresses[i], amount*balances[addresses[i]]*coinCashRates[addresses[i]]/totalSupply_/100);
        }
    }

    function getNthAddress(uint n) public view returns (address) {
        return addresses[n];
    }

    function getIndex(address addr) public view returns (uint) {
        return indices[addr];
    }

    function setCoinCashRate(uint percentOfCoin) public returns (bool) {
        require(percentOfCoin >= 0 && percentOfCoin <= 100);
        coinCashRates[msg.sender] = percentOfCoin;
    }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if (indices[_to] == 0 && _to != addresses[0]) {
            addresses.length += 1;
            addresses[addresses.length-1] = _to;
            indices[_to] = addresses.length-1;
        }
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

   /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        if (indices[_to] == 0) {
            addresses.length += 1;
            addresses[addresses.length-1] = _to;
            indices[_to] = addresses.length-1;
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

}
