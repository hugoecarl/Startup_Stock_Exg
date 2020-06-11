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

        return subask(price, amount, 100);
    }

    function bid(uint256 price, uint256 amount) public returns (bool) {
        address id = msg.sender;
        if (shareholders[id].capital < amount * price || amount * price < 0) {
            return false;
        }
        shareholders[id].capital -= amount * price;

        return subbid(price, amount, 0);
    }

    function subask(
        uint256 price,
        uint256 amount,
        uint256 limit
    ) private returns (bool) {
        address id = msg.sender;
        bool found = false;
        uint256 i;

        Order memory order;
        order.shareholder = id;
        order.price = price;
        order.amount = amount;

        if (amount <= 0) {
            return true;
        }
        uint256 length;

        for (i = price + limit; i >= price; i--) {
            length = bids[i].orders.length;
            if (length > 0) {
                found = true;
                break;
            }
        }

        if (!found) {
            asks[price].orders.push(order);
            return false;
        }

        Order memory tmp = bids[i].orders[length - 1];
        shareholders[tmp.shareholder].capital += 30;
        uint256 traded = amount;

        if (tmp.amount == traded) {
            delete (bids[i].orders[length - 1]);
            bids[i].orders.length--;
        } else if (tmp.amount < traded) {
            delete (bids[i].orders[length - 1]);
            bids[i].orders.length--;
            traded = tmp.amount;
            order.amount -= traded;
            subask(price, amount - traded, i - price);
        } else {
            bids[i].orders[length - 1].amount -= traded;
        }
        shareholders[id].capital += traded * tmp.price;
        shareholders[tmp.shareholder].tokens += traded;
        return true;
    }

    function subbid(
        uint256 price,
        uint256 amount,
        uint256 start
    ) private returns (bool) {
        address id = msg.sender;
        bool found = false;
        uint256 i;

        Order memory order;
        order.shareholder = id;
        order.price = price;
        order.amount = amount;

        uint256 length;

        for (i = start; i <= price; i++) {
            length = asks[i].orders.length;
            if (length > 0) {
                found = true;
                break;
            }
        }

        if (!found) {
            bids[price].orders.push(order);
            return false;
        }

        Order memory tmp = asks[i].orders[length - 1];
        shareholders[tmp.shareholder].capital += 30;
        uint256 traded = amount;

        if (tmp.amount == traded) {
            delete (asks[i].orders[length - 1]);
            asks[i].orders.length--;
        } else if (tmp.amount < traded) {
            delete (asks[i].orders[length - 1]);
            asks[i].orders.length--;
            traded = tmp.amount;
            order.amount -= traded;
            if (order.amount <= 0) {
                return true;
            } else {
                subbid(price, order.amount, i);
            }
        } else {
            asks[i].orders[length - 1].amount -= traded;
        }
        shareholders[tmp.shareholder].capital += traded * tmp.price;
        shareholders[id].tokens += traded;
        return true;
    }

    function deposit() external payable {
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
}
