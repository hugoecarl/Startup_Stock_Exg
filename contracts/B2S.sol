pragma solidity >=0.4.21 <0.7.0;


contract B2S {
    address public owner;
    uint256 public capital;
    uint256 public requiredDeposit;

    enum events {ASK, BID}

    struct Client {
        address payable id;
        uint256 capital;
    }

    struct Company {
        address payable id;
        bool approved;
        uint256 deposit;
        uint256 capital;
    }

    struct Shareholder {
        address shareholder;
        uint256 amount;
    }

    struct Stock {
        address company;
        mapping(address => Shareholder) shareholders;
    }

    struct Ipo {
        address company;
        uint256 price;
        uint256 amount;
    }

    struct Order {
        address shareholder;
        address company;
        uint256 price;
        uint256 amount;
        events action;
    }

    // Maps a company adress to the company information
    mapping(address => Company) public companies;
    mapping(address => Client) public clients;
    mapping(address => Stock) public stocks;

    Order[] public bids;
    Order[] public asks;
    Ipo[] public ipos;

    // Declare contract with the owner as the sender address
    constructor() public payable {
        owner = msg.sender;
        capital += msg.value;
        requiredDeposit = 1;
    }

    modifier restricted() {
        require(msg.sender == owner, "Sender not authorized.");
        // Do not forget the "_;"! It will
        // be replaced by the actual function
        // body when the modifier is used.
        _;
    }

    function ask(
        address shareholder,
        address company,
        uint256 price,
        uint256 amount
    ) public returns (bool) {
        address id = msg.sender;

        Order memory order;
        order.shareholder = shareholder;
        order.company = company;
        order.price = price;
        order.amount = amount;
        order.action = events.ASK;

        if (companies[id].id != address(0)) {
            return true;
        } else if (clients[id].id != address(0)) {
            return true;
        }

        return false;
    }

    // Register new company and retains deposit
    function register() public payable {
        if (msg.value >= requiredDeposit) {
            companies[msg.sender].id = msg.sender;
            companies[msg.sender].deposit = msg.value;
            companies[msg.sender].approved = false;
        } else {
            capital += msg.value;
        }
    }

    function approve(address company, bool approved) public restricted {
        uint256 amount = companies[company].deposit;
        companies[company].approved = approved;
        companies[company].deposit = 0;
        if (approved && amount > 0) {
            companies[company].id.transfer(amount);
        } else {
            capital += amount;
        }
    }

    // Modify the required price to register new company
    function modifyDeposit(uint256 price) public restricted {
        requiredDeposit = price;
    }

    function IPO(uint256 amount, uint256 price) public returns (bool) {
        address company = msg.sender;
        bool _approved = companies[company].approved;
        // Create temporary variable
        Ipo memory request;
        request.company = company;
        request.amount = amount;
        request.price = price;

        // If the company is approved and the amounts are valid
        if (_approved && price > 0 && amount > 0) {
            ipos.push(request);
            return true;
        }

        return false;
    }

    function approveIPO(uint256 index, bool approved) public restricted {
        Ipo memory request = ipos[index];

        address company = request.company;
        uint256 amount = request.amount;
        uint256 price = request.price;

        if (index >= ipos.length) return;

        for (uint256 i = index; i < ipos.length - 1; i++) {
            ipos[i] = ipos[i + 1];
        }
        delete ipos[ipos.length - 1];

        if (approved) {
            stocks[company].company = company;
            stocks[company].shareholders[company].shareholder = company;
            stocks[company].shareholders[company].amount = amount;

            ask(company, company, amount, price);
        }
    }

    function withdraw(uint256 amount) public returns (bool) {
        address id = msg.sender;

        if (companies[id].id != address(0)) {
            uint256 _capital = companies[id].capital;
            bool _approved = companies[id].approved;

            if (!_approved && _capital <= 0 && amount > _capital) return false;

            companies[id].capital -= amount;
            companies[id].id.transfer(amount);
            return true;
        } else if (clients[id].id != address(0)) {
            uint256 _capital = clients[id].capital;
            if (_capital <= 0 && amount > _capital) return false;

            clients[id].capital -= amount;
            clients[id].id.transfer(amount);
            return true;
        }
        return false;
    }

    // Modify the required price to register new company
    function ownerWithdraw(address payable destination, uint256 amount)
        public
        restricted
        returns (bool)
    {
        // If the client has sufficient funds
        if (capital > 0 && amount >= capital) {
            capital -= amount;
            destination.transfer(amount);
            return true;
        }

        return false;
    }

    // Client only
    function deposit() public payable {
        address payable id = msg.sender;
        clients[id].id = msg.sender;
        clients[id].capital += msg.value;
    }

    function getCompanyApproval(address company) public view returns (bool) {
        return companies[company].approved;
    }

    function getCompanyCapital(address company) public view returns (uint256) {
        return companies[company].capital;
    }

    function getCompanyDeposit(address company) public view returns (uint256) {
        return companies[company].deposit;
    }

    function getClientCapital(address client) public view returns (uint256) {
        return companies[client].capital;
    }
}
