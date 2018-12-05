pragma solidity ^0.4.23;

import "../openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "../openzeppelin-solidity/contracts/ownership/Ownable.sol";


// Abstract contract
contract BuildTokenContract {
   function transferByOwnerRemote(address _from, address _to, uint256 _value) external returns (bool success);
}

// Main contract
contract ProjectToken is StandardToken, Ownable {
    BuildTokenContract public token;
    address public owner;
    string public name;
    string public symbol = 'PROJECT_BUILD';
    uint8 public decimals = 2;
    string facts = '연이율 = 0.12, 투자기간 = 3개월, 모금액 = 55000000, 연체금리 = 0.2, 상환방식 = payment upon maturity of the project';
    string product_title = '홍대입구역 Airbnb 도시민박업 사업 담보상품-베타';

    constructor(address _contractAddress, address _fintech_address, uint INITIAL_SUPPLY, string _name) public {
        owner = msg.sender;
        totalSupply_ = INITIAL_SUPPLY;
        balances[_fintech_address] = INITIAL_SUPPLY;
        token = BuildTokenContract(_contractAddress);
        name = _name;
    }

    function endInvestment(address _fintech_address, address _borrower, address[] _investors, uint256[] _amount) public onlyOwner returns (bool success) {
        require(msg.sender == owner);
        require(_investors.length == _amount.length);
        require(_investors.length > 0);
        require(balances[_fintech_address] == totalSupply_);

        uint total_amount = 0;

        // Fintech account gives all PJTs to the investors
        for(uint32 i=0; i<_investors.length; i++) {
            require(_fintech_address != _investors[i]);
            require(_amount[i] > 0);
            require(balances[_fintech_address] >= _amount[i]);
            balances[_fintech_address] = balances[_fintech_address].sub(_amount[i]);
            balances[_investors[i]] = balances[_investors[i]].add(_amount[i]);
            emit Transfer(_fintech_address, _investors[i], _amount[i]);
            total_amount = total_amount.add(_amount[i]);
        }

        // Fintech account gives all BBTs to the borrower
        token.transferByOwnerRemote(_fintech_address, _borrower, total_amount);

        // Borrower gives all the BBTs right away to the BB_MAIN_WALLET
        token.transferByOwnerRemote(_borrower, owner, total_amount);

        return true;
    }

    function returnInvestment(address[] _investors, uint256[] _amount) public onlyOwner returns (bool success) {
        require(msg.sender == owner);
        require(_investors.length == _amount.length);
        require(_investors.length > 0);

        // BuildBlock gives back all the investment principals
        for(uint32 i=0; i<_investors.length; i++) {
            require(owner != _investors[i]);
            require(_amount[i] > 0);
            require(balances[_investors[i]] == _amount[i]);
            token.transferByOwnerRemote(owner, _investors[i], _amount[i]);
        }

        return true;
    }

    function transferByOwner(address _from, address _to, uint256 _value) public onlyOwner returns (bool success) {
        require(msg.sender == owner);
        require(_to != address(0));
        require(_from != _to);
        require(_value <= balances[_from]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] =  balances[_to].add(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    /**
    * @dev Transfers the current balance to the owner and terminates the contract.
    */
    function destroy() public onlyOwner {
        selfdestruct(owner);
    }
}
