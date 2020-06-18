pragma solidity >=0.4.21 <0.7.0;

contract B2S {
    address payable owner;
    uint256 public capital;
    uint256 public minimum;

    struct Company {
        address payable company;
        address exchange;
        uint256 deposit;
        bool approved;
    }

    mapping(address => Company) public companies;

    // Declare contract with the owner as the sender address
    constructor() public {
        owner = msg.sender;
        capital = 0;
        minimum = 10;
    }

    modifier restricted() {
        require(msg.sender == owner, "Sender not authorized.");
        // Do not forget the "_;"! It will
        // be replaced by the actual function
        // body when the modifier is used.
        _;
    }

    function register(address exchange) external payable {
        if (msg.value < minimum) return;
        address payable id = msg.sender;
        companies[exchange].company = id;
        companies[exchange].exchange = exchange;
        companies[exchange].approved = false;
        companies[exchange].deposit = msg.value;
    }j

    function approve(address exchange, bool approved)
        public
        restricted()
        returns (bool)
    {
        uint256 amount = companies[exchange].deposit;
        companies[exchange].deposit = 0;
        companies[exchange].approved = approved;

        if (amount <= 0) return false;

        if (approved) {
            companies[exchange].company.transfer(amount);
            return true;
        }

        capital += amount;
        return false;
    }

    function verify(address exchange) public view returns (bool) {
        return companies[exchange].approved;
    }

    function balance() public view restricted() returns (uint256) {
        return capital;
    }
}
