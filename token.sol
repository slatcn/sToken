// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed spender, uint256 value);
    event Mint(address indexed receiver, uint256 value);
    event SetOwner(address indexed owner);
}


contract Token is IERC20 {
    using SafeMath for uint256;

    string public constant name = "S Token";
    string public constant symbol = "S";
    uint8 public constant decimals = 8;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_;
    address owner_;

    constructor(uint256 total) public {
        owner_ = msg.sender;
        totalSupply_ = total;
        balances[msg.sender] = totalSupply_;

        emit Mint(owner_, totalSupply_);
    }

    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function getOwner() public view returns (address) {
        return owner_;
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) external override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    function mint(address receiver, uint256 numTokens) public returns (bool) {
        require(msg.sender == owner_);
        balances[receiver] = balances[receiver].add(numTokens);
        totalSupply_ = totalSupply_.add(numTokens);
        emit Mint(receiver, numTokens);
        return true;
    }

    function burn(address spender, uint256 numTokens) public returns (bool) {
        require(msg.sender == owner_);
        balances[spender] = balances[spender].sub(numTokens);
        totalSupply_ = totalSupply_.sub(numTokens);
        emit Burn(spender, numTokens);
        return true;
    }

    function setOwner(address owner) public returns (bool){
        require(msg.sender == owner_);
        owner_ = owner;
        emit SetOwner(owner_);
        return true;
    }
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}
