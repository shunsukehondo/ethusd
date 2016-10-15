import "ExchangeRateUpdater.sol";
import "StandardToken.sol";

contract EthUSD is ExchangeRateUpdater, StandardToken {
    string public name;
    string public symbol;
    mapping (address => uint256) public balances;

    event Purchase(address indexed from, uint256 value);
    event Withdraw(address indexed from, uint256 value);

    function EthUSD(string _name, string _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function purchase() returns (bool success) {
        if (msg.value > 0) {
            Purchase(msg.sender, msg.value);
            uint amount = (msg.value * exchangeRate) / 1 ether;
            balances[msg.sender] += amount;
            totalSupply += amount;
            Purchase(msg.sender, amount);
            return true;
        } else {
            return false;
        }
    }

    function withdraw(uint amountInCents) returns (bool success) {
        if(balances[msg.sender] >= amountInCents){
            balances[msg.sender] -= amountInCents;
            uint amountInWei = (amountInCents / withdrawExchangeRate()) * 1 ether;
            msg.sender.send(amountInWei);
            totalSupply -= amountInWei;
            Purchase(msg.sender, amountInWei);
            return true;
        } else {
            return false;
        }
    }

    function withdrawExchangeRate() private returns (uint) {
        if(this.balance < (totalSupply * exchangeRate / 1 ether) ) {
          return 1200;
        } else {
            return exchangeRate;
        }
    }
}
