pragma solidity ^0.8.9;

// totalSupply는 토큰의 발행 총량을 알 수 있는 인터페이스입니다.
// balanceOf는 요청한 계정의 잔액이 얼마인지를 알기 위해 사용됩니다.
// transfer는 토큰을 다른사람에게 이전하기 위해 사용됩니다다.
// approve는 다른 사람에게 정해진 금액 만큼 인출할 권리를 부여합니다.
// allowance는 다른 사람에게 허가한 금액의 허용 잔액이 얼마인지를 나타냅니다.
// transferFrom은 승인된 허가를 받은 사람이 토큰을 보낼 때 사용됩니다. 예를 들어, 여러분의 잔액을 A가 허가하에 B에게 전송하는 경우입니다. 사전에 approve를 통해 승인이 되어 있어야 합니다.

contract ERC20 {
    // Token Information
    string public _name = "HuntingMasterToken";
    string public _symbol = "HMT";
    uint256 public _totalSupply = 0;
    uint8 public _decimals = 18;
    
    mapping(address owner => uint amount) public balances;
    // 누가, 누구에게, 얼마만큼 권한을 주었는가?
    mapping(address owner => mapping(address spender => uint)) public allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Functions
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        address owner = msg.sender;
        require(balances[owner] >= _value);

        balances[owner] -= _value;
        balances[_to] += _value;
        emit Transfer(owner, _to, _value);
        return true;
        
        // 1. Error
        // 2. Data Update
        // 3. Event
        // 4. Return True
    }

    // 실행 주체: spender(Uniswap/Exchange)
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >=  _value);
        require(allowances[_from][_to] >= _value);

        balances[_from] -= _value;
        balances[_to] += _value;
        allowances[_from][_to] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
        // 1. Error
        //      (1) 잔액이 충분한가? owner's balance >= _value
        //      (2) 권한이 있는가? spender's allowance >= _value
        // 2. Data Update
        // 3. Event
        // 4. return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        address _owner = msg.sender;
        allowances[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }
}