// File: @openzeppelin/upgrades/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.6.0;

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {
    /**
   * @dev Indicates that the contract has been initialized.
   */
    bool private initialized;

    /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
    bool private initializing;

    /**
   * @dev Modifier to use in the initializer function of a contract.
   */
    modifier initializer() {
        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        uint256 cs;
        assembly {
            cs := extcodesize(address)
        }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}

// File: contracts/Verify.sol

pragma solidity ^0.5.0;

contract Verify {
    function isValidData(
        string memory _word,
        bytes memory sig,
        address importantAddress
    ) public pure returns (bool) {
        bytes32 message = keccak256(abi.encodePacked(_word));
        return (recoverSigner(message, sig) == importantAddress);
    }

    function recoverSigner(bytes32 message, bytes memory sig)
        public
        pure
        returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }
    function splitSignature(bytes memory sig)
        public
        pure
        returns (uint8, bytes32, bytes32)
    {
        require(
            sig.length == 65,
            "There is an error with the signature length: Verify contract line 29"
        );
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }
}

// File: contracts/WordStorage.sol

pragma solidity ^0.5.0;

contract WordStorage is Initializable {
    uint256 public totalWords;
    string public language;
    address public wordDao;
    address payable public ethReceiver;
    uint256 public fee;

    /********
    MODIFIERS
    ********/

    // Modifier that allows only the WordDao to administer the storage, copied from Moloch
    modifier onlyWordDao {
        require(
            msg.sender == wordDao,
            "WordStorage:: The sender is not the WordDao"
        );
        _;
    }

    // Modifier that requires a payment in the amount equal to the fee,
    // And sends the fee off to a predetermined address.
    modifier requireFeePayment {
        require(msg.value >= fee, "Requires Payment");
        ethReceiver.transfer(msg.value);
        _;
    }

    /********
    STORAGE
    ********/

    //MAPPING
    mapping(uint256 => string) internal wordByNumber;
    mapping(string => uint256) internal numberForWord;
    mapping(bytes32 => string) internal wordByBytes32;
    mapping(string => bytes32) internal bytes32ForWord;
    mapping(uint256 => bytes32) internal uint256ForBytes32;
    mapping(bytes32 => uint256) internal bytes32ForWordUint256;

    mapping(string => bool) public wordExists;

    //ARRAYS
    bytes32[] internal arrayOfBytes32;
    uint256[] internal arrayOfUint256;
    string[] internal arrayOfWords;

    /********
    EVENTS
    ********/

    //wordAdded
    event wordAdded(
        string word,
        address indexed from,
        uint256 wordNumber,
        bytes32 indexed wordBytes32
    );
    event wordRequested(uint256 wordNumber, address indexed requestor);
    event storageCreated(
        string language,
        uint256 fee,
        address storageAddress,
        address wordDao,
        address fundRecipient
    );
    event feeChanged(uint256 fee);

    /********
    CODE
    ********/

    function setupStorage(
        string memory _language,
        uint256 _fee,
        address payable _ethReceiver,
        address _owner
    ) public initializer {
        language = _language;
        wordDao = _owner;
        fee = _fee;
        ethReceiver = _ethReceiver;
        emit storageCreated(
            language,
            fee,
            address(this),
            msg.sender,
            ethReceiver
        );
    }

    /********
    SETTERS
    ********/

    function changeFee(uint256 _fee) external onlyWordDao {
        fee = _fee;
        emit feeChanged(fee);
    }

    function setWord(string memory _word) public onlyWordDao returns (bool) {
        bytes32 _wordBytes32 = keccak256(abi.encodePacked(_word));
        wordByNumber[totalWords] = _word;
        numberForWord[_word] = totalWords;
        wordByBytes32[_wordBytes32] = _word;
        bytes32ForWord[_word] = _wordBytes32;
        uint256ForBytes32[totalWords] = _wordBytes32;
        bytes32ForWordUint256[_wordBytes32] = totalWords;
        arrayOfBytes32.push(_wordBytes32);
        arrayOfWords.push(_word);
        arrayOfUint256.push(totalWords);
        totalWords = totalWords + 1;
        wordExists[_word] = true;
        emit wordAdded(_word, msg.sender, totalWords, _wordBytes32);

        return true;
    }

    /********
    Internal(ish) Getter  (NonPaid)
    ********/

    //Get the integer value of a word, by word, allowed only for wordDao
    function getWordStringToUint256forDao(string calldata _word)
        external
        view
        onlyWordDao
        returns (uint256)
    {
        return numberForWord[_word];
    }

    /********
    PUBLIC GETTERS (FOR PAYMENT) 
    ********/

    //Get the integer value of a word, by word
    function getWordStringToUint256(string calldata _word)
        external
        payable
        requireFeePayment
        returns (uint256)
    {
        emit wordRequested(numberForWord[_word], msg.sender);
        return numberForWord[_word];
    }

    //Get bytes32 value for a word, by word.
    function getWordStringToBytes32(string calldata _word)
        external
        payable
        returns (bytes32)
    {
        emit wordRequested(numberForWord[_word], msg.sender);
        return bytes32ForWord[_word];
    }

    //Get string value for a word, by integer
    function getWordUint256ToString(uint256 _wordNumber)
        external
        payable
        requireFeePayment
        returns (string memory)
    {
        emit wordRequested(_wordNumber, msg.sender);
        return wordByNumber[_wordNumber];
    }

    //Get bytes32 value for a word, by integer
    function getWordUint256ToBytes32(uint256 _wordNumber)
        external
        payable
        requireFeePayment
        returns (bytes32)
    {
        emit wordRequested(_wordNumber, msg.sender);
        return uint256ForBytes32[_wordNumber];
    }

    //Get string value for a word, by bytes32
    function getWordBytes32ToString(bytes32 _wordBytes)
        external
        payable
        requireFeePayment
        returns (string memory)
    {
        emit wordRequested(bytes32ForWordUint256[_wordBytes], msg.sender);
        return wordByBytes32[_wordBytes];
    }

    //Get integer value for a word, by bytes32
    function getWordBytes32ToUint256(bytes32 _wordBytes)
        external
        payable
        requireFeePayment
        returns (uint256)
    {
        emit wordRequested(bytes32ForWordUint256[_wordBytes], msg.sender);
        return bytes32ForWordUint256[_wordBytes];
    }

    /********
    UTILS
    ********/

    // //Transfer function incase there is  value  left in the contract
    // function transferEther() external payable onlyWordDao {
    //     ethReceiver.transfer(address(this).balance);
    // }

}

// File: contracts/StorageFactory.sol

pragma solidity ^0.5.0;

contract StorageFactory {
    function createWordStorage(
        string memory _language,
        uint256 _wordFee,
        address payable _fundRecipent,
        address _owner
    ) public returns (WordStorage) {
        WordStorage wordStorage = new WordStorage();
        wordStorage.setupStorage(_language, _wordFee, _fundRecipent, _owner);
        return wordStorage;
    }

}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Implementation of the `IERC20` interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using `_mint`.
 * For a generic mechanism see `ERC20Mintable`.
 *
 * *For a detailed writeup see our guide [How to implement supply
 * mechanisms](https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226).*
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an `Approval` event is emitted on calls to `transferFrom`.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard `decreaseAllowance` and `increaseAllowance`
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See `IERC20.approve`.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See `IERC20.totalSupply`.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See `IERC20.balanceOf`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See `IERC20.transfer`.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See `IERC20.allowance`.
     */
    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See `IERC20.approve`.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See `IERC20.transferFrom`.
     *
     * Emits an `Approval` event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of `ERC20`;
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount)
        public
        returns (bool)
    {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(amount)
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(subtractedValue)
        );
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `Transfer` event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount)
        internal
    {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destoys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an `Approval` event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See `_burn` and `_approve`.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            msg.sender,
            _allowances[account][msg.sender].sub(amount)
        );
    }
}

// File: @openzeppelin/contracts/token/ERC20/ERC20Detailed.sol

pragma solidity ^0.5.0;

/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name, string memory symbol, uint8 decimals)
        public
    {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * > Note that this information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * `IERC20.balanceOf` and `IERC20.transfer`.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

// File: contracts/WordToken.sol

pragma solidity ^0.5.0;

contract WordToken is ERC20, ERC20Detailed {
    constructor(
        uint256 initialSupply,
        string memory _tokenName,
        string memory _tokenSymbol
    ) public ERC20Detailed(_tokenName, _tokenSymbol, 18) {
        _mint(msg.sender, initialSupply);
    }
}

// File: contracts/WordDao.sol

pragma solidity ^0.5.0;

// import "./WordStorage.sol";

contract WordDao is Initializable, Verify {
    //TODO: Decide if the WordDao should delegateCall the requests to the storage, or if the storage should be addressed inidividually.
    //PROS: DelegateCall would make the code more DRY and the storage units could reduce their code
    //CONS: might introduce more complexity
    //TODO: Make everything an upgradable instance
    //PROS: We can upgrade whenever
    //CONS?: We need to involve the OZ SDK programatic libray for increased complexity.
    //TODO: Mint ERC721 Tokens for users that would like them.
    //TODO: Improve ERC20 minting situation
    //TODO: Calculate the Tribute to a fixed amount. (Use DAI?)

    /********
    Storage Variables
    ********/

    //Address of the ERC20 token that is given to users who contribute words
    //WordToken public token;
    mapping(bytes32 => WordToken) public tokens;

    //Address of WordStorageFactory
    StorageFactory public storageFactory;

    //Address of the WordStorage that is created by the WordDao contract
    //Track Multiple Storage Units
    mapping(bytes32 => WordStorage) public storageUnits;
    mapping(bytes32 => string) public storageLanguage;
    WordStorage[] public storageUnitArray;
    uint256 public storageCount;

    //Balance of this contract. This should be set to a seperate contract (gnosis safe?)
    uint256 public contractBalance;

    //The payment required to set a word.
    mapping(bytes32 => uint256) public tribute;

    //The payment required to set a vanity word.
    mapping(bytes32 => uint256) public vanityTribute;

    //The signature Authority that is required to have signed the words before adding them.
    mapping(bytes32 => address) public signAuthority;

    //Address of the Dao contract which controls the WordDao
    address public DAOController;

    //Address of the initial Administrator for the WordDao. Once setup, it should be transfered
    //To the DAOController.
    address public owner;

    /********
    MODIFIERS
    ********/

    //This requires that contract be from the owner. Owner can be set  to be  MasterDao.
    modifier onlyMaster {
        require(msg.sender == owner, "WordDao:: Only Master DAO can Control");
        _;
    }

    modifier wordDoesNotExist(string memory _word, string memory _language) {
        bytes32 pointer = getStoragePointer(_language);
        require(
            storageUnits[pointer].wordExists(_word) == false,
            "WordDAO: Vanity Check: Word has already been Added"
        );
        _;
    }

    //Not clear  that we need this. Funds should be move out of Dao.
    //Not needed only DAO can withdraw anyway.
    //Should seperate money from Find.
    //To prevent Reentrancy  for withdrawls. Copied from Moloch Dao.
    // bool locked;
    // modifier noReentrancy() {
    //     require(!locked, "WordDao: Reentrant call");
    //     locked = true;
    //     _;
    //     locked = false;
    // }

    /********
    EVENTS
    ********/

    event wordAdded(
        string word,
        uint256 indexed wordIndex,
        uint256 tribute,
        bool vanity,
        address adder
    );

    event daoMaster(address daoMaster);
    event fundsTransfered(address destination, uint256 amount);
    event storageCreated(
        string language,
        bytes32 storagePointer,
        uint256 fee,
        uint256 tribute,
        uint256 vanityTribute,
        uint256 wordCount,
        address storageContract,
        address signAuthority
    );

    event setTribute(uint256 fee, string language);
    event setFee(uint256 fee, string language);

    /********
    FUNCTIONS
    ********/

    //TODO: Make Sign Authority changable

    //WordDao Setup
    function setupDao(StorageFactory _storageFactory) public initializer {
        //Set inital contract values
        owner = msg.sender;
        storageFactory = _storageFactory;
    }

    function addWordStorage(
        string memory _language,
        uint256 _fee,
        uint256 _tribute,
        uint256 _vanityTribute,
        uint256 _totalWordCount,
        address _signAuthority
    ) public onlyMaster {
        _createStorage(
            _language,
            _fee,
            _tribute,
            _vanityTribute,
            _totalWordCount,
            _signAuthority
        );
    }

    //Set the controller of the WordDao.
    //Todo: his needs a more robust system. It should allow for a setup time, a dao, transfer to  down, and renounce control.
    function setMaster(address _dao) public onlyMaster {
        DAOController = _dao;
        emit daoMaster(_dao);
    }

    function setOwnerToDao() public onlyMaster {
        owner = DAOController;
    }

    //Add a word to the DAO.
    function addWord(
        string memory _language,
        string memory _word,
        bytes memory _signature,
        bool _vanity
    ) public payable wordDoesNotExist(_word, _language) {
        bytes32 _storagePointer = getStoragePointer(_language);
        require(
            msg.value >= tribute[_storagePointer],
            "WordDAO: Vanity Check: Tribute not high enough"
        );

        if (_vanity) {
            require(
                msg.value - vanityTribute[_storagePointer] > 0,
                "WordDAO: Vanity Check: Vanity fee not high enough"
            );
        } else {
            require(
                isValidData(_word, _signature, signAuthority[_storagePointer]),
                "WordDAO: Word Not Valid"
            );
        }

        storageUnits[_storagePointer].setWord(_word);
        tokens[_storagePointer].transfer(msg.sender, 1);
        contractBalance += msg.value;

        emit wordAdded(
            _word,
            storageUnits[_storagePointer].getWordStringToUint256forDao(_word),
            msg.value,
            _vanity,
            msg.sender
        );
    }

    //Set the fee required to access a word.
    function setUseFee(uint256 _fee, string calldata _language)
        external
        onlyMaster
    {
        emit setFee(_fee, _language);
        storageUnits[getStoragePointer(_language)].changeFee(_fee);
    }

    //Set the Fee required to add a word.
    function setTributeFee(uint256 _fee, string calldata _language)
        external
        onlyMaster
    {
        //In wei
        tribute[getStoragePointer(_language)] = _fee;
        emit setTribute(_fee, _language);
    }

    //Get the balance of the WordDao Contract itself.
    function getWordDaoBalance() public view returns (uint256) {
        return address(this).balance;
    }

    //Withdraw the Balance of the WordDao Contract
    //There should be a seperate Contract for splitting payments to Token Holders.
    function withDraw(uint256 _amount, address payable _destination)
        public
        onlyMaster
    {
        require(_amount > 0, "Amount must be greater than zero");
        require(
            _amount <= address(this).balance,
            "Amount must be less than or equal to balance"
        );
        address(_destination).transfer(_amount);
        emit fundsTransfered(_destination, _amount);
    }

    //Utility Function to get the Storage Pointer Name from string into bytes32
    function getStoragePointer(string memory _storageName)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_storageName));
    }

    function _createStorage(
        string memory _language,
        uint256 _fee,
        uint256 _tribute,
        uint256 _vanityTribute,
        uint256 _totalWordCount,
        address _signAuthority
    ) internal {
        //DRY: Storage pointer
        bytes32 _storagePointer = getStoragePointer(_language);
        tribute[_storagePointer] = _tribute;
        vanityTribute[_storagePointer] = _vanityTribute;
        //Setup the token with the tokens availible. This should be fixed to fix token supply.
        //Need to Extract this part to a new internal function
        WordToken tempToken = new WordToken(
            _totalWordCount,
            _language,
            _language
        );
        tokens[_storagePointer] = tempToken;

        //Cast the address of this contract, the WordDao to address payable
        address payable fundRecipent = address(uint160(address(this)));

        //Create a new wordStorage
        //TODO: Explore using Create2 to create wordStorage, this way we can predict their locations
        WordStorage wordStorage = storageFactory.createWordStorage(
            _language,
            _fee,
            fundRecipent,
            address(uint160(address(this)))
        );

        //Store the created WordStorage in the Storage Units
        storageUnitArray.push(wordStorage);
        storageUnits[_storagePointer] = wordStorage;
        storageLanguage[_storagePointer] = _language;
        storageCount += 1;

        //Set the address that has the authority to sign new words
        // signAuthority = address(0x76991b32A0eE1996E5c3dB5FdD29029882D587DF);
        signAuthority[_storagePointer] = _signAuthority;

        emit storageCreated(
            _language,
            _storagePointer,
            _fee,
            _tribute,
            _vanityTribute,
            _totalWordCount,
            address(storageUnits[_storagePointer]),
            signAuthority[_storagePointer]
        );
    }

}
