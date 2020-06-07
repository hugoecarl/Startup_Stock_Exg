pragma solidity >=0.4.21 <0.7.0;


contract B2S {
    address public owner;
    uint256 public capital;
    uint256 public requiredDeposit;

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
    }

    // Maps a company adress to the company information
    mapping(address => Company) public companies;
    mapping(address => Client) public clients;
    mapping(address => Stock) public stocks;

    mapping(address => Order[]) public bids;
    mapping(address => Order[]) public asks;

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
        address company,
        uint256 price,
        uint256 amount
    ) public returns (bool) {
        address id = msg.sender;

        Order memory order;
        order.shareholder = id;
        order.company = company;
        order.price = price;
        order.amount = amount;

        if (stocks[company].shareholders[id].amount < amount || amount < 0) {
            return false;
        }

        if (companies[id].id != address(0)) {
            if (!companies[id].approved) return false;
        }

        stocks[company].shareholders[id].amount -= amount;

        for (uint256 i = 0; i < bids[company].length; i++) {
            if (bids[company][i].price >= price) {
                uint256 _amount = bids[company][i].amount;
                uint256 _price = bids[company][i].price;
                address _shareholder = bids[company][i].shareholder;

                if (amount == _amount) {
                    uint256 traded = amount;
                    bids[company][i].amount -= traded;
                    clients[id].capital += _price * traded;
                    stocks[company].shareholders[_shareholder].amount += traded;
                    stocks[company].shareholders[_shareholder]
                        .shareholder = _shareholder;
                    removeBid(company, i);
                    break;
                } else if (amount < _amount) {
                    uint256 traded = amount;
                    bids[company][i].amount -= traded;
                    clients[id].capital += _price * traded;
                    stocks[company].shareholders[_shareholder].amount += traded;
                    stocks[company].shareholders[_shareholder]
                        .shareholder = _shareholder;
                    break;
                } else {
                    uint256 traded = _amount;
                    amount -= traded;
                    clients[id].capital += _price * traded;
                    stocks[company].shareholders[_shareholder].amount += traded;
                    stocks[company].shareholders[_shareholder]
                        .shareholder = _shareholder;
                    removeBid(company, i);
                    i--;
                }
            }
        }

        return false;
    }

    function addBid(
        address company,
        Order memory order,
        uint256 index
    ) private {
        Order memory tmp;
        bids[company].push(tmp);
        for (uint256 i = bids[company].length; i > index; i--) {
            bids[company][i] = bids[company][i - 1];
        }
        bids[company][index] = order;
    }

    function removeBid(address company, uint256 index) private {
        for (uint256 i = index; i < bids[company].length - 1; i++) {
            bids[company][i] = bids[company][i + 1];
        }
        delete bids[company][bids[company].length - 1];
    }

    function addAsk(
        address company,
        Order memory order,
        uint256 index
    ) private {
        Order memory tmp;
        asks[company].push(tmp);
        for (uint256 i = asks[company].length; i > index; i--) {
            asks[company][i] = asks[company][i - 1];
        }
        asks[company][index] = order;
    }

    function removeAsk(address company, uint256 index) private {
        for (uint256 i = index; i < asks[company].length - 1; i++) {
            asks[company][i] = asks[company][i + 1];
        }
        delete asks[company][asks[company].length - 1];
    }

    function bid(
        address company,
        uint256 price,
        uint256 amount
    ) public returns (bool) {
        address id = msg.sender;

        Order memory order;
        order.shareholder = id;
        order.company = company;
        order.price = price;
        order.amount = amount;

        if (companies[id].id != address(0)) {
            return true;
        } else if (clients[id].id != address(0)) {
            return true;
        }

        bids[company].push(order);
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

            ask(company, amount, price);
        }
    }

    function withdraw(uint256 amount) public returns (bool) {
        address id = msg.sender;

        // if the company and the client has the same address then this will not work
        if (companies[id].id != address(0)) {
            uint256 _capital = companies[id].capital;
            bool _approved = companies[id].approved;

            if (!_approved || _capital <= 0 || amount > _capital) return false;

            companies[id].capital -= amount;
            companies[id].id.transfer(amount);
            return true;
        } else if (clients[id].id != address(0)) {
            uint256 _capital = clients[id].capital;
            if (_capital <= 0 || amount > _capital) return false;

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
