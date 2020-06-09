pragma solidity >=0.4.21 <0.7.0;


contract Company {
    struct Shareholder {
        address payable id;
        uint256 tokens;
        uint256 capital;
    }

    struct Order {
        address shareholder;
        uint256 price;
        uint256 amount;
    }

    address public owner;
    address payable company;
    uint256 public capital;

    // Maps a company adress to the company information
    mapping(address => Shareholder) public shareholders;
    mapping(uint256 => Order[]) public bids;
    mapping(uint256 => Order[]) public asks;

    // Declare contract with the owner as the sender address
    constructor() public {
        company = msg.sender;
        capital = 0;
    }

    modifier restricted() {
        require(msg.sender == owner, "Sender not authorized.");
        // Do not forget the "_;"! It will
        // be replaced by the actual function
        // body when the modifier is used.
        _;
    }

    function ask(uint256 price, uint256 amount) public view returns (bool) {
        address id = msg.sender;

        Order memory order;
        order.shareholder = id;
        order.price = price;
        order.amount = amount;

        if (shareholders[id].tokens < amount || amount < 0) {
            return false;
        }

        return false;
    }

    function withdraw(uint256 amount) public returns (bool) {
        address id = msg.sender;
        uint256 _capital = shareholders[id].capital;
        if (_capital <= 0 || amount > _capital) return false;
        shareholders[id].capital -= amount;
        shareholders[id].id.transfer(amount);
        return true;
    }

    function balance() public view returns (uint256) {
        address id = msg.sender;
        return shareholders[id].capital;
    }

    function deposit() public payable {
        address payable id = msg.sender;
        shareholders[id].id = id;
        shareholders[id].capital = 10;
    }
}
