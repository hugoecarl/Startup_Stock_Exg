pragma solidity >=0.4.21 <0.7.0;


contract B2S {
    address payable public owner;
    Company[] public contracts;

    uint256 capital;

    struct Client {
        address payable id;
        uint256 tokens;
        uint256 capital;
    }

    struct Order {
        address shareholder;
        uint256 price;
        uint256 amount;
    }

    // Maps a company adress to the company information
    mapping(address => Client) public clients;
    mapping(uint256 => Order[]) public bids;
    mapping(uint256 => Order[]) public asks;

    // Declare contract with the owner as the sender address
    constructor() public {
        owner = msg.sender;
        capital = 0;
    }

    modifier restricted() {
        require(msg.sender == owner, "Sender not authorized.");
        // Do not forget the "_;"! It will
        // be replaced by the actual function
        // body when the modifier is used.
        _;
    }

    function approve(bool approved) public restricted {
        uint256 amount = contracts[0].getGuarantee();
        address payable company = contracts[0].getCompany();
        contracts[0].approve(approved);
        if (approved && amount > 0) {
            company.transfer(amount);
        } else {
            owner.transfer(amount);
        }
    }

    function register() public payable returns (address company) {
        Company c = new Company(owner, msg.sender, msg.value);
        contracts.push(c);
        return address(c);
    }
}


contract Company {
    struct Context {
        uint256 guarantee;
        bool approved;
    }

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
    Context public context;

    // Maps a company adress to the company information
    mapping(address => Shareholder) public shareholders;
    mapping(uint256 => Order[]) public bids;
    mapping(uint256 => Order[]) public asks;

    // Declare contract with the owner as the sender address
    constructor(
        address ownerAddress,
        address payable companyAddress,
        uint256 guarantee
    ) public {
        owner = ownerAddress;
        company = companyAddress;
        context.guarantee = guarantee;
        context.approved = false;
        capital = 0;
    }

    modifier restricted() {
        require(msg.sender == owner, "Sender not authorized.");
        // Do not forget the "_;"! It will
        // be replaced by the actual function
        // body when the modifier is used.
        _;
    }

    function approve(bool approved) public restricted {
        context.approved = approved;
        context.guarantee = 0;
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

    function getCompany() public view returns (address payable) {
        return company;
    }

    function getGuarantee() public view returns (uint256) {
        return context.guarantee;
    }

    function getApproval() public view returns (bool) {
        return context.approved;
    }

    function withdraw(uint256 amount) public returns (bool) {
        address id = msg.sender;
        uint256 _capital = shareholders[id].capital;
        if (_capital <= 0 || amount > _capital) return false;
        shareholders[id].capital -= amount;
        shareholders[id].id.transfer(amount);
        return true;
    }

    // Client only
    function deposit() public payable {
        address payable id = msg.sender;
        shareholders[id].id = msg.sender;
        shareholders[id].capital += msg.value;
    }
}
