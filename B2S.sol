pragma solidity ^0.6.8;


// https://solidity.readthedocs.io/en/v0.6.8/common-patterns.html
contract B2S {
    address public owner;
    uint256 public capital;
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

    struct Stakeholder {
        address stakeholder;
        uint256 amount;
    }

    struct Stock {
        address company;
        mapping(address => Stakeholder) stakeholders;
    }

    struct Order {
        address stakeholder;
        address company;
        uint256 price;
        uint256 amount;
        events action;
    }

    // Maps a company adress to the company information
    mapping(address => Company) public companies;
    mapping(address => Client) public clients;
    mapping(address => Stock) public stocks;

    // Declare contract with the owner as the sender address
    constructor() public payable {
        owner = msg.sender;
    }

    modifier onlyBy(address _account) {
        require(msg.sender == _account, "Sender not authorized.");
        // Do not forget the "_;"! It will
        // be replaced by the actual function
        // body when the modifier is used.
        _;
    }

    function register() public payable {
        companies[msg.sender].id = msg.sender;
        companies[msg.sender].deposit = msg.value;
        companies[msg.sender].approved = false;
    }

    function approve(address company, bool approved) public onlyBy(owner) {
        uint256 amount = companies[company].deposit;
        companies[company].deposit = 0;
        if (approved && amount > 0) {
            companies[company].id.transfer(amount);
        } else {
            capital += amount;
        }
    }

    // Company only
    function companyWithdraw(uint256 amount) public returns (bool) {
        address company = msg.sender;
        uint256 _capital = companies[company].capital;
        bool _approved = companies[company].approved;
        // If the company is aprooved and has sufficient funds
        if (_approved && _capital > 0 && amount >= _capital) {
            companies[company].capital -= amount;
            companies[company].id.transfer(amount);
            return true;
        }

        return false;
    }

    // Client only
    function clientWithdraw(uint256 amount) public returns (bool) {
        address client = msg.sender;
        uint256 _capital = clients[client].capital;
        // If the client has sufficient funds
        if (_capital > 0 && amount >= _capital) {
            clients[client].capital -= amount;
            clients[client].id.transfer(amount);
            return true;
        }

        return false;
    }

    // Client only
    function clientDeposit() public payable {
        address payable id = msg.sender;
        clients[id].id = msg.sender;
        clients[id].capital += msg.value;
    }
}
