pragma solidity ^0.6.6;

import '@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';

library SM {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ERC20{
    using SafeMath for uint256;
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;
    
    
    uint256 private _totalSupply;

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

   
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

   
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

   
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }


    function _burnFrom(address account, uint256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}

/**
 * @title ERC20Mintable
 * @dev ERC20 minting logic
 */
contract ERC20Mintable is ERC20{
    address owneraddress;
    constructor () internal {
        owneraddress=msg.sender;
    }
    modifier onlyowner {
        require(owneraddress == msg.sender);
        _;
    }
    function mint(address to, uint256 value) onlyowner public returns (bool) {
        _mint(to, value);
        return true;
    }
}

/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is ERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }


    function symbol() public view returns (string memory) {
        return _symbol;
    }


    function decimals() public view returns (uint8) {
        return _decimals;
    }
}


contract INDEXTOKEN is ERC20Mintable, ERC20Detailed {
    event debug(uint256 out);
    uint8 public constant DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 0;
    address[] public _tokens;
    uint8[] internal  _parts;
    address internal constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D ;
    address internal constant WETH = 0xc778417E063141139Fce010982780140Aa0cD5Ab ;
    address internal constant PUSD = 0xC11090b333e0a8a88cb5d26f1f663CF859fcB861 ;
    address internal constant owner = 0x409676686041B31DD59939D1484348e07DFbD8A1;
    IUniswapV2Router02 public uniswapRouter;
    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor (address[] memory tokens,uint8[] memory parts) public payable ERC20Detailed("INDEXT", "IDT", DECIMALS) {
        for(uint i=0;i<tokens.length;i++){
            _tokens.push(tokens[i]);
        }
        for(uint i=0;i<parts.length;i++){
            _parts.push(parts[i]);
        }
        require(msg.value>=1000,"please send peyment");
        payable(owner).transfer(1000);
        _mint(msg.sender, INITIAL_SUPPLY);
        uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
    }
    function buy(uint256 amount) public{
        for(uint i=0;i<_tokens.length;i++){
            /*
            (bool successe, bytes memory datae) = _tokens[i].call(
                abi.encodeWithSignature("allowance(address,address)", msg.sender, address(this))
            );
            uint256 tempUint; 
            assembly {
                tempUint := mload(add(add(datae, 0x20), 0))
            }
            require(successe && SM.mul(amount,_parts[i])<= tempUint  ,string(abi.encodePacked("error with ",_tokens[i],"maybe allowance is to low")));*/
            (bool successbt,  bytes memory databt) = _tokens[i].call(
                abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, address(this),SM.mul(amount,_parts[i]))
            );
            require(successbt,string(abi.encodePacked("error with ",_tokens[i],"maybe allowance is to low")));
        }
        
        _mint(msg.sender,amount);

    }
    function sell(uint256 amount) public{
        for(uint i=0;i<_tokens.length;i++){
            (bool successbt, bytes memory databt) =  _tokens[i].call(
                abi.encodeWithSignature("transfer(address,uint256)",msg.sender,SM.mul(amount,_parts[i]))
            );
            require(successbt,"err");
             
        }
       
        _burn(msg.sender,amount);
    }
    function sellUSD(uint256 amount) public{
        uint8 a=0;
        uint256 amountOUT;
        if(_tokens[0]==WETH){
            address[] memory path = new address[](2);
            path[0]=WETH;
            path[1]=PUSD;
            amountOUT=SM.div(SM.mul(uniswapRouter.getAmountsOut(SM.mul(amount,_parts[0]),path)[0],100),101);
            emit debug(amountOUT);
            uniswapRouter.swapExactTokensForTokens(SM.mul(amount,_parts[0]),amountOUT,path,msg.sender,block.timestamp+25);
            a=1;
            
        }
        for(uint i=a;i<_tokens.length;i++){
            address[] memory path2 = new address[](3);
            path2[0]=_tokens[i];
            path2[1]=WETH;
            path2[2]=PUSD;
            amountOUT=SM.div(SM.mul(uniswapRouter.getAmountsOut(SM.mul(amount,_parts[i]),path2)[0],100),101);
            uniswapRouter.swapExactTokensForTokens(SM.mul(amount,_parts[i]),amountOUT,path2,msg.sender,block.timestamp+25);
        }
       
        _burn(msg.sender,amount);
    }
    function buyUSD(uint256 amount) public{
        uint8 a=0;
        uint256 amountIN;
        if(_tokens[0]==WETH){
            address[] memory path = new address[](2);
            path[0]=PUSD;
            path[1]=WETH;
            amountIN=SM.div(SM.mul(uniswapRouter.getAmountsIn(SM.mul(amount,_parts[0]),path)[0],101),100);
            uniswapRouter.swapExactTokensForTokens(amountIN,SM.mul(amount,_parts[0]),path,msg.sender,block.timestamp+25);
            a=1;
            
        }
        for(uint i=a;i<_tokens.length;i++){
            address[] memory path2 = new address[](3);
            path2[0]=PUSD;
            path2[1]=WETH;
            path2[2]=_tokens[i];
            amountIN=SM.div(SM.mul(uniswapRouter.getAmountsIn(SM.mul(amount,_parts[i]),path2)[0],101),100);
            uniswapRouter.swapExactTokensForTokens(amountIN,SM.mul(amount,_parts[i]),path2,msg.sender,block.timestamp+25);
        }
        /*
        uint256 weth=SM.div(SM.mul(uniswapRouter.getAmountsIn(amount,path)[0],101),100);
        address[] memory path2 = new address[](3);
        path[0]=PUSD;
        path[1]=WETH;
        path[2]=PBTC;
        uint256 pbtc=SM.div(SM.mul(uniswapRouter.getAmountsIn(amount*2,path2)[0],101),100);
        (bool successet, bytes memory dataet) = PUSD.call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, address(this),weth+pbtc)
        );
        require(successet);
        uniswapRouter.swapExactTokensForTokens(weth,amount,path,address(this),block.timestamp+25);
        uniswapRouter.swapExactTokensForTokens(pbtc,amount,path2,address(this),block.timestamp+25);
        */
        
        
        //uint256 pbtc=uniswapRouter.getAmountsIn(amount);
        
        
        _mint(msg.sender,amount);
    }

}

contract TESTER{
    function get() public{
        address UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D ;
       
        address PUSD = 0xC11090b333e0a8a88cb5d26f1f663CF859fcB861 ;
        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS); 
        address WETH = uniswapRouter.WETH() ;
        address[] memory path = new address[](2);
        path[0]=uniswapRouter.WETH();
        path[1]=PUSD;
        uint256 amountOUT=uniswapRouter.getAmountsOut(1,path)[1];
      
        (bool success,  bytes memory data) = WETH.call(
                abi.encodeWithSignature("approve(address,uint256)",UNISWAP_ROUTER_ADDRESS,20000)
        );
        require(success,"err");
        uniswapRouter.swapExactTokensForTokens(1,amountOUT,path,msg.sender,block.timestamp+25);
        //return amountIN;
    }
    function got() public view returns (address){
        address UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D ;
       
        address PUSD = 0xC11090b333e0a8a88cb5d26f1f663CF859fcB861 ;
        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS); 
        return uniswapRouter.WETH();
    }
}

