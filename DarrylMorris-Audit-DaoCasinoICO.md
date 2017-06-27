# ICO Code Audit for DAO Casino
## Overview
This is an independent 'eyes-over' audit of Solidity ICO contracts for *Dao Casino*. 
Auditor: Darryl Morris aka o0ragman0o
Contact:  o0ragman0o@gmail.com
Date: 27 June 2017

Web presence: [dao.casino](https://dao.casino/)
[White Paper](https://github.com/DaoCasino/Whitepaper/blob/master/DAO.Casino%20WP.md)
White Paper chapter https://github.com/DaoCasino/Whitepaper/blob/master/DAO.Casino%20WP.md#22-token-system
Multiple source code links were provided of differing versions, however the most recent complete code was found to be located at:
gist: [https://gist.github.com/noxonsu/dd3ea77e3c077389c8b66e0ee358821a](https://gist.github.com/noxonsu/dd3ea77e3c077389c8b66e0ee358821a)

This gist for `DaoCasinoICO` includes a collation of all necessary contract source and stipulates the current Solidity version specified in the pragma string.  The source audited for this document is therefore only for that found in this gist.

Deployment Instructions: [https://github.com/airalab/dao.casino/issues/13](https://github.com/airalab/dao.casino/issues/13)

## Disclaimer
The limited time frame given for auditing before the deployment for crowdfunding is insufficient for extensive tests by this auditor.
Issues raised here may not be an exhaustive list of all possible issues with the source code, its deployment and its operation.
The auditor has no prior relationship with the developers or the project.
The auditor does not intend to invest in the project.
The auditor is not held liable for damages arising from the project.
The author reserves the right to publicise this audit without further permission from the the project.


## Summary of Findings and Recommendations
* **! Critical Issue: Backdoor !**: The owner of the `DaoCasinoICO` **can unconditionally withdraw funds** using `DaoCasino.withdrawEth()` **during the fund raising** which is a direct violation of the *refund on failure* policy as encoded in `Crowdfunding.refund()`.

##### Deployment
* **Serious Issue**: Ownership (custody) of the `TokenEmission` contract instance is not automatically given to the `DaoCasino` contract resulting in a potential breach of trust which **allows the owner to create and transfer unlimited tokens prior to handover.**

##### Owned
* Include a `receiveOwnerShip()` function to mitigate *possible catastrophic loss* of control if an incorrect address is given to `setOwner()`. 
* Use constructor to set `owner` value.

##### Destroyable
* Include a `receiveHammer()` function to mitigate *possible loss* of control if an incorrect address is given to `setHammer()`. 
* Use constructor to set `hammer` value.

##### Object
* Use a hierarchical constructor pattern to assign state variables `owner` and `hammer`. 

##### ERC20
* Rename to indicate it is an abstract interface contract.
* Include all ERC20 interface abstract functions.
* Remove state variable `totalSupply` as it is overloaded by contract `Token`.

##### Token
* Transfer functions do not use bounding checks.

##### TokenEmission
* **Serious Issue: Potential breach of trust:** The owner can create unlimited tokens prior to assigning ownership to the crowd funding contract.
**Recommendation**: Redesign deployment strategy to avoid potential breach of trust.
 
##### Recipient
No issues found

##### Crowdfunding
* Layout is untidy.

##### DaoCasinoICO
* **Critical Issue: Backdoor ** `withdrawEth()` is not modified with `onlySuccess`. Funds can be unconditionally removed by owner at any time.
* The `BLOCKS_IN_DAY` constant is not calculated at current average block time. The funding period may extend beyond 29 days.
* `withdraw()` inappropriately overloads `Crowdfunding.withdraw()`
* `withdrawEth()` should overload `Crowdfunding.withdraw()`
* Apply `onlySuccess` modifier to `withdrawEth()`
* Rename `withdraw()` -> `withdrawBounty()`
* Rename `withdrawEth()` -> `withdraw()`
* Hoist state declarations together and hoist modifiers above functions.
* `participants` array is unnecessary. Use event log to gather participant data.

## Contracts
* Owned
* Destroyable
      * Object is Owned, Destroyable
* ERC20
      * Token is Object, ERC20
          * TokenEmission is Token
* Recipient
    * Crowdfunding is Object, Recipient
        * DaoCasinoICO is Crowdfunding 

## Analysis
### Coding Style
The coding style is clean and reasonably follows the [Solidity Style Guide](http://solidity.readthedocs.io/en/develop/style-guide.html) though the larger contracts have untidy layout.

Documentation is according to the [*Ethereum Natural Specification Format (NatSpec)*](https://github.com/ethereum/wiki/wiki/Ethereum-Natural-Specification-Format)

The code provided does not contain a file description comment block.
There is no versioning or date information in the source code.
There is no licensing or copyright information or acknowledgement of use of licensed or copyrighted source code (if such code has been used).

Permissions logic uses obsolete patterns.

**Recommendation** Use industry accepted versioning, licensing and citations.
**Recommendation** Use `require()` for permissions rather than `if() throw` pattern.

### Compiler
Compiler pragma allows the contract to be compiled in Solidity version 0.4.11 or later which is the current stable release.

All contracts compile without error in Solidity version 0.4.11.

Four `unused local variable` warnings present for function
`receiveApproval(address _from, uint256 _value, ERC20 _token, bytes _extraData)`.  This function is overloads intentionally throws on all cases, thus not requiring parameter usage.  Warnings can be ignored.

**Recommendation:** No recommendations.

### Deployment
DaoCasinoICO deployment instructions have been provided.
Deployment parameters have not been provided.

### Contract Analysis
#### Owned
##### State
`address public owner;`

Has public getter which is appropriate for this variable.
##### Modifiers 
`modifier onlyOwner { if (msg.sender != owner) throw; _; }`

This modifier is logically consistent.
##### Functions
This contract has no constructor or other means to initially set the value of `owner`.  Though the contract is written to be inherited, it is not in itself an *abstract contract* and so breaks the principle of encapsulation.

No default function is defined and is not required.

`function setOwner(address _owner) onlyOwner`

Only `owner` can modify `owner`.

**Serious Issue:** This contract does not handle the possibility of an *incorrect* `setOwner()` parameter.  Setting `owner` to an incorrect address would result in ***catastrophic loss of control*** of the contract.

**Recommendation:** Include a `receiveOwnerShip()` function for the new owner to confirm its ability to own the contract.
**Recommendation:** Set the `owner` variable via the constructor.

#### Destroyable
##### State
`address public hammer;`

Has public getter which is appropriate for this variable.

##### Modifiers
`modifier onlyHammer { if (msg.sender != hammer) throw; _; }`

This modifier is logically consistent though uses an obsolete pattern

##### Functions
This contract has no constructor or other means to initially set the value of `hammer`.  Though the contract is written to be inherited, it is not in itself an *abstract contract* and so breaks the principle of encapsulation.

`function setHammer(address _hammer) onlyHammer`

Only the hammer can change the hammer.

`function destroy() onlyHammer`

Only the hammer can destroy the contract.

**Warning:** This contract does not handle the possibility of an *incorrect* new `hammer` address.  Setting `hammer` to an incorrect address would result in an ***inability to destroy the contract***.

**Recommendation:** Include a `receiveHammer()` function for the new hammer to confirm its ability to destroy the contract.
**Recommendation:** Set the `hammer` variable via the constructor.

#### Object is Owned, Destroyable
 This contract inherits `Owned` and `Destroyable` and consists only of a constructor.  
`function Object()`

This constructor explicitly sets both `owner` and `hammer` in the base contracts.  To maintain consistency with encapsulation principles, the constructor should call the constructors of the inherited contracts rather than explicitly set the state variables.

**Recommendation** Consider using the existing hierarchical constructor pattern to initialise `owner` and `hammer` state variables. 

#### ERC20
ERC20 is an abstract contract interface expected to follow the ERC20 standard.
It should not contain state variables but only abstract functions as specified in the ERC20 standard.

This contract *does not* indicate by its name that it is an *interface* contract which is in contrast to industry practice.
##### State
`uint256 public totalSupply;` 

This variable is also defined in the `Token` contract which will overload it and therefore presents as a bug.
This should be replaced here with the abstract getter function definition.

##### Functions
The following function abstracts are in accordance with an ERC20 interface.
```
function balanceOf(address _owner) constant returns (uint256);
function transfer(address _to, uint256 _value) returns (bool);
function transferFrom(address _from, address _to, uint256 _value) returns (bool);
function approve(address _spender, uint256 _value) returns (bool);
function allowance(address _owner, address _spender) constant returns (uint256);
```

Function abstracts which are missing are:
```
function name() constant returns (string);
function symbol() constant returns (string);
function totalSupply() constant returns (uint256);
function decimals() constant returns (uint8);
```


##### Events
The following events are inaccordance with the ERC20 standard
`event Transfer(address indexed _from, address indexed _to, uint256 _value);`
`event Approval(address indexed _owner, address indexed _spender, uint256 _value);`

**Bug:** Remove state variable `totalSupply`.
**Recommendation:** Define abstract functions for public state variables `name`, `symbol`, `decimalPlaces`, `totalSupply`.
**Recommendation:** Rename the contract to indicate it is an abstract interface.

#### Token is Object, ERC20
`Token` derives from `Object` and `ERC20`

##### State
`string public name;`

Is in accordance with the ERC20 token standard.

`string public symbol;`

Is in accordance with the ERC20 token standard.

`uint256 public totalSupply;`

Is in accordance with the ERC20 token standard.

`uint8 public decimals;`

Is in accordance with the ERC20 token standard.

`mapping(address => uint256) balances;`

Is in accordance with the ERC20 token standard.
Unless there is an intention for dynamic calculation for the `balanceOf()` getter, this variable *may* be made public and defined as `mapping(address => uint256) public balanceOf;` which removes the requirement for an explicit `balanceOf()` getter.

`mapping(address => mapping(address => uint256)) allowances;`
Is in accordance with the ERC20 token standard.
Unless there is an intention for dynamic calculation for the `allowance()` getter, this variable *may* be made public and defined as `mapping(address => uint256) public balanceOf;` which removes the requirement for an explicit `balanceOf()` getter.

##### Functions
`function Token(string _name, string _symbol, uint8 _decimals, uint256 _count)`

No issues found.

`function balanceOf(address _owner) constant returns (uint256)`

This getter function may be removed by renaming `balances` to `balanceOf` and modifying as `public`.

`function allowance(address _owner, address _spender) constant returns (uint256)`

This getter function may be removed by renaming `allowances` to `allowance` and modifying as `public`;

`function transfer(address _to, uint256 _value) returns (bool)`

Does not use overflow/underflow checking on addition and subtractions.

`function transferFrom(address _from, address _to, uint256 _value) returns (bool)`

Does not use overflow/underflow checking on addition and subtractions.

`approve(address _spender, uint256 _value) returns (bool)`

No issues found.

`function unapprove(address _spender)`

Is not necessary and not an ERC20 standard function as `approve()` can perform the same function.  Appears to be included as a courtesy.
No issues found.

**Consideration:** Consider `public` modified state functions for getters.

#### TokenEmission
TokenEmission derives from Token
##### State
No additional state consumed.
##### Functions

```
function TokenEmission(string _name, string _symbol, uint8 _decimals, uint _start_count)
```
No issues found

```
function emission(uint _value) onlyOwner {
        // Overflow check
        if (_value + totalSupply < totalSupply) throw;
        totalSupply     += _value;
        balances[owner] += _value;
}
```
This function allows for the unconstrained creation of tokens by the contract owner. Given that the deployment instructions allow for an indefinite period of of time between contract deployment and ownership transference to the `DaoCasinoICO` contract instance, there is a **significant potential for breach of trust prior to fundraising**.

`function burn(uint _value)`

While logically consistent, it is unclear why this function is required.

**Recommendation**: Redesign deployment strategy to avoid potential breach of trust.
**Recommendation**: Clarify the roll of `burn()` or remove the function.
 
#### Recipient
Recipient is a base level contract
##### State
No state is consumed.
##### Events
```
event ReceivedEther(address indexed sender, uint256 indexed amount);
event ReceivedTokens(address indexed from, uint256 indexed value, address indexed token, bytes extraData);
```

No issues found.
##### Functions
`function () payable`

No issues found

`function receiveApproval(address _from, uint256 _value, ERC20 _token, bytes _extraData)`

No issues found

#### Crowdfunding
`contract Crowdfunding is Object, Recipient`

##### State
`address public fund;`

This is the address of the account to which raised funds are transferred.  This address is set through the constructor and should be publicised prior to the crowd sale.

`TokenEmission public bounty;`

This is the address of the `TokenEmission` instance which is the BET ERC20 token implementation.  That implementation and its custody has *numerous issues which need to be addressed prior to crowd funding*.

`mapping(address => uint256) public donations;`

This state keeps a record of tokens to be issued to funders after closing the crowd sale.

`uint256 public totalFunded;`

This state keep a record of total ether raised.

`public reference;`

This state holds a reference string for documentation

`Params public config;`

This state records the deployment and control parameters that were passed to the constructor.

#### Structs
`struct Params {...}`

A struct to hold initial and operational parameters.
A state optimisation would be realised if certain of these values were to use lower order `uint` such as `uint128` or `uint64`.

#### Modifiers
`modifier onlyRunning`

This modifier is logically consistent though uses an obsolete pattern

`modifier onlyFailure` 

This modifier is logically consistent though uses an obsolete pattern

`modifier onlySuccess`

This modifier is logically consistent though uses an obsolete pattern

##### Functions

`function bountyValue(uint256 _value, uint256 _block) constant returns (uint256)`

This function is overloaded by `DaoCasino.bountryValue()` and so has no effect upon the deployment.  It is however out of line in the source code and should be placed after the modifiers with the the other functions.

`function Crowdfunding(...)`

Constructor. Parameters are passed through from the deriving contract's constructor.

`function () payable onlyRunning`

No issues found

`function withdraw() onlySuccess`

This function is intended to allow withdrawal of collected ether funds to the fund address after the fund raising has succeded.  It is however overloaded by `DaoCasino.withdraw() onlySuccess` which is of an entirely different nature as it deals with the transference of tokens.

`function refund() onlyFailure`

This function encodes the refund policy upon a failed fund raising.
This function is **critically compromised by the ability of the owner of `DaoCasinoICO` to unconditionally remove funds before the fundraising period has completed.**

`function receiveApproval(address _from, uint256 _value, ERC20 _token, bytes  extraData)`
This function rejects token `approve` notifications with it as the approved sender.

#### DaoCasinoICO
`contract DaoCasinoICO is Crowdfunding`

This is the contract to be deployed to the blockchain.
The declaration layout of this contract is untidy.
**Recommendation:** Hoist state declarations together and hoist modifiers above (or below) functions.

##### State
`uint256 public constant BLOCKS_IN_DAY = 5256;`

This constant is calculated for 16.44 second block times. At the time of audit, average block times over the past 5000 blocks is 17.4s.  This pushes the estimated 28 day funding period to approximately 29.7 days.

`uint256 public minDonation;`

A state to test for minimum accepted payment during funding.

`bool withdrawDone = false;`

A withdraw flag called by `withdraw()`. 
**Recommendation:** This declaration is out of order in the source. Keep state declarations together
**Recommendation:** Invert logic so as to free state when no longer required.

`mapping(address => uint256) public bounties;`

This state mirrors the token amounts to be translated to the `bounty` tokens contract upon a successful fund
**Recommendation:** This declaration is out of order in the source. Keep state declarations together

`address[] public participants;`

This state holds the address of all funding accounts.
The contents are not referenced by any functions in the contract and as the same information can be gather through the logs, make it a redundant use of state.
**Recommendation:** Remove the state declaration and the append operation in in the default function.

##### Modifiers
`modifier onlySuccess {...}`

This modifier is logically consistent though uses an obsolete pattern.
This modifier is used by `getBounty()` and `withdraw()`.  It **must** be used in `withdrawEth()` but is not, allowing instead for the fund to be unconditionally  withdrawn by the contract owner prior to a successful funding.

##### Functions
`function DaoCasinoICO(...)`

Required parameters are passed through to the `CrowdFunding` constructor.
`minDonation` assigned accordingly
No issues found

`function () payable onlyRunning`

Use of `participants` array is unnecessary and access to participant information should be through event logs. 
**Recommendation:** Remove use of `participants`

`function bountyValue(uint256 _value, uint256 _block) constant returns (uint256)`

No issues found

```
function withdrawEth() onlyOwner {
        if (!fund.send(this.balance)) throw;
    }
```
**! Critical Issue: Backdoor!**: The owner of the `DaoCasinoICO` **can unconditionally withdraw funds** using `DaoCasino.withdrawEth()` **during the and after the fund raising** which is a direct violation of the *refund on failure* policy as encoded in `Crowdfunding.refund()`.

This function should overload `Crowdfunding.withdraw()`.

**Recommendation:** Additionally modify `withdrawEth()` with `onlySuccess`. 
**Recommendation:** Rename function to `withdraw()` in order to overload `Crowdfunding.withdraw()` which deals with ether values. 

```
function withdraw() onlySuccess`
{
    /**
     * @dev 30% emission on success
     */
    function withdraw() onlySuccess {
        if (withdrawDone) throw;
        withdrawDone = true;

        var bountyVal = bounty.totalSupply() * 30 / 70;
        bounty.emission(bountyVal);
        if (!bounty.transfer(fund, bountyVal)) throw;
    }
```
This function overloads `Crowdfunding.withdraw()` but entirely changes the nature of that function from a withdrawal of ether value to a transfer of tokens.

**Recommendation:** Rename function `withdraw()`  so as not to inappropriately overload `Crowdfunding.withdraw()`. 

`function getBounty(address _participant) onlySuccess`

This function transfers BET tokens from the `bounty` token contract's owner account to the participant account pending a successful funding.

No issues found

`function getMyBounty()`

This function allows sender to have their BET tokens moved from the owner account to their own.

No issues found

### Appendix
```
pragma solidity ^0.4.11;
/* compiled from  https://github.com/airalab/dao.casino/blob/master/contracts/DaoCasinoICO.sol */
/**
 * @title Contract for object that have an owner
 */
contract Owned {
    /**
     * Contract owner address
     */
    address public owner;

    /**
     * @dev Delegate contract to another person
     * @param _owner New owner address 
     */
    function setOwner(address _owner) onlyOwner
    { owner = _owner; }

    /**
     * @dev Owner check modifier
     */
    modifier onlyOwner { if (msg.sender != owner) throw; _; }
}

/**
 * @title Common pattern for destroyable contracts 
 */
contract Destroyable {
    address public hammer;

    /**
     * @dev Hammer setter
     * @param _hammer New hammer address
     */
    function setHammer(address _hammer) onlyHammer
    { hammer = _hammer; }

    /**
     * @dev Destroy contract and scrub a data
     * @notice Only hammer can call it 
     */
    function destroy() onlyHammer
    { suicide(msg.sender); }

    /**
     * @dev Hammer check modifier
     */
    modifier onlyHammer { if (msg.sender != hammer) throw; _; }
}

/**
 * @title Generic owned destroyable contract
 */
contract Object is Owned, Destroyable {
    function Object() {
        owner  = msg.sender;
        hammer = msg.sender;
    }
}

// Standard token interface (ERC 20)
// https://github.com/ethereum/EIPs/issues/20
contract ERC20 
{
// Functions:
    /// @return total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool);

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256);

// Events:
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}



/**
 * @title Token contract represents any asset in digital economy
 */
contract Token is Object, ERC20 {
    /* Short description of token */
    string public name;
    string public symbol;

    /* Total count of tokens exist */
    uint256 public totalSupply;

    /* Fixed point position */
    uint8 public decimals;

    /* Token approvement system */
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;

    /* Token constructor */
    function Token(string _name, string _symbol, uint8 _decimals, uint256 _count) {
        name        = _name;
        symbol      = _symbol;
        decimals    = _decimals;
        totalSupply = _count;
        balances[msg.sender] = _count;
    }

    /**
     * @dev Get balance of plain address
     * @param _owner is a target address
     * @return amount of tokens on balance
     */
    function balanceOf(address _owner) constant returns (uint256)
    { return balances[_owner]; }

    /**
     * @dev Take allowed tokens
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent
     */
    function allowance(address _owner, address _spender) constant returns (uint256)
    { return allowances[_owner][_spender]; }

    /**
     * @dev Transfer self tokens to given address
     * @param _to destination address
     * @param _value amount of token values to send
     * @notice `_value` tokens will be sended to `_to`
     * @return `true` when transfer done
     */
    function transfer(address _to, uint256 _value) returns (bool) {
        if (balances[msg.sender] >= _value) {
            balances[msg.sender] -= _value;
            balances[_to]        += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    /**
     * @dev Transfer with approvement mechainsm
     * @param _from source address, `_value` tokens shold be approved for `sender`
     * @param _to destination address
     * @param _value amount of token values to send
     * @notice from `_from` will be sended `_value` tokens to `_to`
     * @return `true` when transfer is done
     */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        var avail = allowances[_from][msg.sender]
                  > balances[_from] ? balances[_from]
                                    : allowances[_from][msg.sender];
        if (avail >= _value) {
            allowances[_from][msg.sender] -= _value;
            balances[_from] -= _value;
            balances[_to]   += _value;
            Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    /**
     * @dev Give to target address ability for self token manipulation without sending
     * @param _spender target address (future requester)
     * @param _value amount of token values for approving
     */
    function approve(address _spender, uint256 _value) returns (bool) {
        allowances[msg.sender][_spender] += _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Reset count of tokens approved for given address
     * @param _spender target address (future requester)
     */
    function unapprove(address _spender)
    { allowances[msg.sender][_spender] = 0; }
}

contract TokenEmission is Token {
    function TokenEmission(string _name, string _symbol, uint8 _decimals,
                           uint _start_count)
             Token(_name, _symbol, _decimals, _start_count)
    {}

    /**
     * @dev Token emission
     * @param _value amount of token values to emit
     * @notice owner balance will be increased by `_value`
     */
    function emission(uint _value) onlyOwner {
        // Overflow check
        if (_value + totalSupply < totalSupply) throw;

        totalSupply     += _value;
        balances[owner] += _value;
    }
 
    /**
     * @dev Burn the token values from sender balance and from total
     * @param _value amount of token values for burn 
     * @notice sender balance will be decreased by `_value`
     */
    function burn(uint _value) {
        if (balances[msg.sender] >= _value) {
            balances[msg.sender] -= _value;
            totalSupply      -= _value;
        }
    }
}

/**
 * @title Asset recipient interface
 */
contract Recipient {
    /**
     * @dev On received ethers
     * @param sender Ether sender
     * @param amount Ether value
     */
    event ReceivedEther(address indexed sender,
                        uint256 indexed amount);

    /**
     * @dev On received custom ERC20 tokens
     * @param from Token sender
     * @param value Token value
     * @param token Token contract address
     * @param extraData Custom additional data
     */
    event ReceivedTokens(address indexed from,
                         uint256 indexed value,
                         address indexed token,
                         bytes extraData);

    /**
     * @dev Receive approved ERC20 tokens
     * @param _from Spender address
     * @param _value Transaction value
     * @param _token ERC20 token contract address
     * @param _extraData Custom additional data
     */
    function receiveApproval(address _from, uint256 _value,
                             ERC20 _token, bytes _extraData) {
        if (!_token.transferFrom(_from, this, _value)) throw;
        ReceivedTokens(_from, _value, _token, _extraData);
    }

    /**
     * @dev Catch sended to contract ethers
     */
    function () payable
    { ReceivedEther(msg.sender, msg.value); }
}

/**
 * @title Crowdfunding contract
 */
contract Crowdfunding is Object, Recipient {
    /**
     * @dev Target fund account address
     */
    address public fund;

    /**
     * @dev Bounty token address
     */
    TokenEmission public bounty;
    
    /**
     * @dev Distribution of donations
     */
    mapping(address => uint256) public donations;

    /**
     * @dev Total funded value
     */
    uint256 public totalFunded;

    /**
     * @dev Documentation reference
     */
    string public reference;

    /**
     * @dev Crowdfunding configuration
     */
    Params public config;

    struct Params {
        /* start/stop block stamps */
        uint256 startBlock;
        uint256 stopBlock;

        /* Minimal/maximal funded value */
        uint256 minValue;
        uint256 maxValue;
        
        /**
         * Bounty ratio equation:
         *   bountyValue = value * ratio / scale
         * where
         *   ratio = R - (block - B) / S * V
         *  R - start bounty ratio
         *  B - start block number
         *  S - bounty reduction step in blocks 
         *  V - bounty reduction value
         */
        uint256 bountyScale;
        uint256 startRatio;
        uint256 reductionStep;
        uint256 reductionValue;
    }

    /**
     * @dev Calculate bounty value by reduction equation
     * @param _value Input donation value
     * @param _block Input block number
     * @return Bounty value
     */
    function bountyValue(uint256 _value, uint256 _block) constant returns (uint256) {
        if (_block < config.startBlock || _block > config.stopBlock)
            return 0;

        var R = config.startRatio;
        var B = config.startBlock;
        var S = config.reductionStep;
        var V = config.reductionValue;
        uint256 ratio = R - (_block - B) / S * V; 
        return _value * ratio / config.bountyScale; 
    }

    /**
     * @dev Crowdfunding running checks
     */
    modifier onlyRunning {
        bool isRunning = totalFunded + msg.value <= config.maxValue
                      && block.number >= config.startBlock
                      && block.number <= config.stopBlock;
        if (!isRunning) throw;
        _;
    }

    /**
     * @dev Crowdfundung failure checks
     */
    modifier onlyFailure {
        bool isFailure = totalFunded  < config.minValue
                      && block.number > config.stopBlock;
        if (!isFailure) throw;
        _;
    }

    /**
     * @dev Crowdfunding success checks
     */
    modifier onlySuccess {
        bool isSuccess = totalFunded >= config.minValue
                      && block.number > config.stopBlock;
        if (!isSuccess) throw;
        _;
    }

    /**
     * @dev Crowdfunding contract initial 
     * @param _fund Destination account address
     * @param _bounty Bounty token address
     * @param _reference Reference documentation link
     * @param _startBlock Funding start block number
     * @param _stopBlock Funding stop block nubmer
     * @param _minValue Minimal funded value in wei 
     * @param _maxValue Maximal funded value in wei
     * @param _scale Bounty scaling factor by funded value
     * @param _startRatio Initial bounty ratio
     * @param _reductionStep Bounty reduction step in blocks 
     * @param _reductionValue Bounty reduction value
     * @notice this contract should be owner of bounty token
     */
    function Crowdfunding(
        address _fund,
        address _bounty,
        string  _reference,
        uint256 _startBlock,
        uint256 _stopBlock,
        uint256 _minValue,
        uint256 _maxValue,
        uint256 _scale,
        uint256 _startRatio,
        uint256 _reductionStep,
        uint256 _reductionValue
    ) {
        fund      = _fund;
        bounty    = TokenEmission(_bounty);
        reference = _reference;

        config.startBlock     = _startBlock;
        config.stopBlock      = _stopBlock;
        config.minValue       = _minValue;
        config.maxValue       = _maxValue;
        config.bountyScale    = _scale;
        config.startRatio     = _startRatio;
        config.reductionStep  = _reductionStep;
        config.reductionValue = _reductionValue;
    }

    /**
     * @dev Receive Ether token and send bounty
     */
    function () payable onlyRunning {
        ReceivedEther(msg.sender, msg.value);

        totalFunded           += msg.value;
        donations[msg.sender] += msg.value;

        var bountyVal = bountyValue(msg.value, block.number);
        if (bountyVal == 0) throw;

        bounty.emission(bountyVal);
        bounty.transfer(msg.sender, bountyVal);
    }

    /**
     * @dev Withdrawal balance on successfull finish
     */
    function withdraw() onlySuccess
    { if (!fund.send(this.balance)) throw; }

    /**
     * @dev Refund donations when no minimal value achieved
     */
    function refund() onlyFailure {
        var donation = donations[msg.sender];
        donations[msg.sender] = 0;
        if (!msg.sender.send(donation)) throw;
    }

    /**
     * @dev Disable receive another tokens
     */
    function receiveApproval(address _from, uint256 _value,
                             ERC20 _token, bytes _extraData)
    { throw; }
}

contract DaoCasinoICO is Crowdfunding {
    /**
     * @dev Crowdfunding contract initial 
     * @param _fund Destination account address
     * @param _bounty Bounty token address (erc20 with emission function)
     * @param _reference Reference documentation link
     * @param _startBlock Funding start block number
     * @param _stopBlock Funding stop block nubmer
     * @param _minValue Minimal funded value in wei 
     * @param _maxValue Maximal funded value in wei
     * @param _scale Bounty scaling factor by funded value
     * @param _startRatio Initial bounty ratio
     * @param _reductionStep Bounty reduction step in blocks 
     * @param _reductionValue Bounty reduction value
     * @notice this contract should be owner of bounty token
     */
    function DaoCasinoICO(
        address _fund,
        address _bounty,
        string  _reference,
        uint256 _startBlock,
        uint256 _stopBlock,
        uint256 _minValue,
        uint256 _maxValue,
        uint256 _scale,
        uint256 _startRatio,
        uint256 _reductionStep,
        uint256 _reductionValue,
        uint256 _minDonation
    ) Crowdfunding(_fund, _bounty, _reference, _startBlock, _stopBlock, _minValue, _maxValue, _scale, _startRatio, _reductionStep, _reductionValue) {
        minDonation = _minDonation;
    }

    /**
     * @dev Receive Ether token and charge bounty
     */
    function () payable onlyRunning {
        // Minimal donation check
        if (msg.value < minDonation) throw;

        ReceivedEther(msg.sender, msg.value);

        totalFunded           += msg.value;
        donations[msg.sender] += msg.value;

        var bountyVal = bountyValue(msg.value, block.number);
        var bountySupply = bounty.totalSupply();

        // Bounty emission for crowdfunding contract
        //   is needed for bounty totalSupply accounting
        bounty.emission(bountyVal);

        // Correct emission check, result should be more
        if (bountySupply == bounty.totalSupply()) throw;

        // Append new participant
        if (bounties[msg.sender] == 0)
            participants.push(msg.sender);

        // Charge bounties
        bounties[msg.sender] += bountyVal;
    }

    // ONLY FOR 16.44s block time
    uint256 public constant BLOCKS_IN_DAY = 5256;

    uint256 public minDonation;

    /**
     * @dev Calculate bounty value by static equation
     * @param _value Input donation value
     * @param _block Input block number
     * @return Bounty value
     */
    function bountyValue(uint256 _value, uint256 _block) constant returns (uint256) {
        uint256 ratio = 0;
        uint256 start = config.startBlock;

        // 1st day bounty
        if (_block >= start && _block < start + BLOCKS_IN_DAY)
            ratio = 2000;

        // [2; 15) day bounty
        if (_block >= start + BLOCKS_IN_DAY && _block < start + 15*BLOCKS_IN_DAY)
            ratio = 1800;

        // [15; 18) day bounty
        if (_block >= start + 15*BLOCKS_IN_DAY && _block < start + 18*BLOCKS_IN_DAY)
            ratio = 1700;

        // [18; 21) day bounty
        if (_block >= start + 18*BLOCKS_IN_DAY && _block < start + 21*BLOCKS_IN_DAY)
            ratio = 1600;

        // [21; 23) day bounty
        if (_block >= start + 21*BLOCKS_IN_DAY && _block < start + 23*BLOCKS_IN_DAY)
            ratio = 1500;

        // [23; 26) day bounty
        if (_block >= start + 23*BLOCKS_IN_DAY && _block < start + 26*BLOCKS_IN_DAY)
            ratio = 1400;

        // [26; 29) day bounty
        if (_block >= start + 26*BLOCKS_IN_DAY && _block <= config.stopBlock)
            ratio = 1300;

        return _value * ratio / config.bountyScale;
    }

    /**
     * @dev Crowdfunding success checks
     */
    modifier onlySuccess {
        bool isSuccess = totalFunded >= config.minValue
                      && block.number > config.stopBlock
                      || totalFunded == config.maxValue;
        if (!isSuccess) throw;
        _;
    }

    /**
     * @dev Withdrawal Ethereum balance
     */
    function withdrawEth() onlyOwner {
        if (!fund.send(this.balance)) throw;
    }

    /**
     * @dev 30% emission on success
     */
    function withdraw() onlySuccess {
        if (withdrawDone) throw;
        withdrawDone = true;

        var bountyVal = bounty.totalSupply() * 30 / 70;
        bounty.emission(bountyVal);
        if (!bounty.transfer(fund, bountyVal)) throw;
    }

    bool withdrawDone = false;
    mapping(address => uint256) public bounties;
    address[] public participants;

    /**
     * @dev Transfer paritication bounty for account
     * @param _participant Account address
     */
    function getBounty(address _participant) onlySuccess {
        var bountyVal = bounties[_participant];
        if (bountyVal == 0) throw;

        bounties[_participant] = 0;
        if (!bounty.transfer(_participant, bountyVal)) throw;
    }

    /**
     * @dev Simple way to get sender account bounty
     */
    function getMyBounty() { getBounty(msg.sender); }
}
```
