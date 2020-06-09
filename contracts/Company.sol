pragma solidity >=0.4.21 <0.7.0;


contract Company {
    address payable owner;

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

    struct Data {
        uint256 price;
        Order[] orders;
    }

    mapping(address => Shareholder) public shareholders;
    mapping(uint256 => Data) public bids;
    mapping(uint256 => Data) public asks;

    // Declare contract with the owner as the sender address
    constructor() public {
        owner = msg.sender;
    }

    modifier restricted() {
        require(msg.sender == owner, "Sender not authorized.");
        // Do not forget the "_;"! It will
        // be replaced by the actual function
        // body when the modifier is used.
        _;
    }

    function ipo(uint256 price, uint256 amount) public restricted() {
        address payable id = msg.sender;
        shareholders[id].id = id;
        // value allocated in order, prevent double spending
        Order memory order;
        order.shareholder = id;
        order.price = price;
        order.amount = amount;

        asks[price].orders.push(order);
        asks[price].price = price;
    }

    function ask(uint256 price, uint256 amount) public returns (bool) {
        address id = msg.sender;
        if (shareholders[id].tokens < amount || amount < 0) {
            return false;
        }

        shareholders[id].tokens -= amount;
        Order memory order;
        order.shareholder = id;
        order.price = price;
        order.amount = amount;

        uint256 length = bids[price].orders.length;

        if (length == 0) {
            asks[price].orders.push(order);
            return false;
        } else {
            Order memory tmp = bids[price].orders[length - 1];
            delete (bids[price].orders[length - 1]);
            shareholders[id].capital += tmp.amount * tmp.price;
            shareholders[tmp.shareholder].tokens += tmp.amount; //amount;
            return true;
        }
    }

    function bid(uint256 price, uint256 amount) public returns (bool) {
        address id = msg.sender;
        if (shareholders[id].capital < amount * price || amount * price < 0) {
            return false;
        }

        shareholders[id].capital -= amount * price;
        Order memory order;
        order.shareholder = id;
        order.price = price;
        order.amount = amount;

        uint256 length = asks[price].orders.length;

        if (length == 0) {
            bids[price].orders.push(order);
            return false;
        } else {
            Order memory tmp = asks[price].orders[length - 1];
            delete (asks[price].orders[length - 1]);
            shareholders[tmp.shareholder].capital += tmp.amount * tmp.price;
            shareholders[id].tokens += tmp.amount; //amount;
            return true;
        }
    }

    function deposit() public payable {
        address payable id = msg.sender;
        shareholders[id].id = id;
        shareholders[id].capital = msg.value;
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

    function shares() public view returns (uint256) {
        address id = msg.sender;
        return shareholders[id].tokens;
    }

    function dummy(uint256 price) public returns (uint256) {
        Order memory order;
        order.price = 10101010;
        asks[price].orders.push(order);
        uint256 length = asks[price].orders.length;
        delete (asks[price].orders[length - 1]);

        length = asks[price].orders.length;
        uint256 p = asks[price].orders[length - 1].price;

        return p;
    }
}
