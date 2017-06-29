# ICO Code Audit for DAO Casino
## Overview
This is an independent 'eyes-over' audit of Solidity ICO contracts for *DAO.Casino*.
Auditor: Darryl Morris aka o0ragman0o
Contact:  o0ragman0o@gmail.com
Date: 29 June 2017

Web presence: [dao.casino](https://dao.casino/)
[White Paper](github.com/DaoCasino/Whitepaper/blob/master/DAO.Casino%20WP.md)
[White Paper chapter for ICO](https://github.com/DaoCasino/Whitepaper/blob/master/DAO.Casino%20WP.md#22-token-system)
Source code:
[github.com/bokkypoobah/DaoCasinoTokenSaleContractAudit/blob/master/contracts/DaoCasinoToken.so](https://github.com/bokkypoobah/DaoCasinoTokenSaleContractAudit/blob/master/contracts/DaoCasinoToken.so)


## Context

This is a second audit for the DAO.Casino ICO. The audit on original contracts revealed multiple areas of concern.  DAO Casino has been responsive to the audit and has been working with Bok Consulting to arrive at a solution before this ICO launches on the 29th June 2017 13:00UC (day of this audit).

As a solution, Bok Consulting has provided DAO.Casino a replacement ICO contract to work under the same parameters as originally specified in the DAO Casino White Paper.

This contract has been **deployed and verified** on the Ethereum live chain at address: 
[0x2b09b52d42dfb4e0cba43f607dd272ea3fe1fb9f](https://etherscan.io/address/0x2b09b52d42dfb4e0cba43f607dd272ea3fe1fb9f#code)

All ether funds collected by the contract will be transferred to the DAO.Casino multisig wallet at:
[0x039704a4ecf78b0e1eef8f181a7838a0c68876ca](https://etherscan.io/address/0x039704a4ecf78b0e1eef8f181a7838a0c68876ca)

## Disclaimer
The limited time frame given for auditing before the deployment for crowdfunding is insufficient for extensive tests by this auditor.

Issues raised here may not be an exhaustive list of all possible issues with the source code, its deployment and its operation.

The auditor has previously audited code for DAO.Casino.

The auditor has been retained by *Bok Consulting* for the purpose of this audit.

The auditor does not intend to invest in the project.

The auditor is not held liable for damages arising from the project.

The auditor reserves the right to publish this audit without further permission from DAO.Casino or Bok Consulting.

## Summary of Findings and Recommendations

**Incorrect funding period:** The ENDDATE reported by the contract allows only 27 days for funding not 28 days. There appear to have been a miscalculation with the `_enddate` parameter passed upon deployment.

**No critical or significant issues have been found with this source code.**

The following considerations and recommendations are not considered critical or significant. 
##### ERC20Token

* **Recommendation** Remove `Owner` as base contract.
* **Consideration**: Define as `uint public totalSupply;` and remove explicit getter function `function totalSupply()`
* **Consideration**: Define as `mapping(address => uint256) public balanceOf;` and remove explicit getter function `function balanceOf(address _addr)`
* **Consideration**: Define as `mapping(address => mapping (address => uint256)) allowance;`
and remove explicit getter function `function allowance(address _owner, address _spender)`
* **Consideration** `totalSupply` getter is not required if recommendations are considered for state variable `_totalSupply`
* **Consideration**  `balanceOf` getter is not required if recommendations are considered for state variable `balances`
* **Consideration**:  Redefine `allowed` as `mapping(address => mapping (address => uint256)) allowance;` and remove explicit getter function `function allowance(address _owner, address _spender)`
* **Recommendation** Change event `Approval` parameter from `_owner` to `_holder`

##### DaoCasinoToken
* **Recommendation** Remove `Owned` from `ERC20` and redefine `DaoCasinoToken` as `contract DaoCasinoToken is Owned, ERC20Token`.
* **Recommendation** An oracle providing the contract a live ETH/USD exchange rate would provide a more consistent fund cap.

## Contracts
Contracts collated in the source code are:

* SafeMath (library) 
* Owned
* ERC20Token is Owned
* DaoCasinoToken is ERCToken

## Analysis
### Coding Style
Source code can be found at:
[etherscan.io/address/0x039704a4ecf78b0e1eef8f181a7838a0c68876ca#code](https://etherscan.io/address/0x039704a4ecf78b0e1eef8f181a7838a0c68876ca#code)

The coding style is clean and reasonably follows the [Solidity Style Guide](http://solidity.readthedocs.io/en/develop/style-guide.html)

The code is well commented but does not follow the [*Ethereum Natural Specification Format (NatSpec)*](https://github.com/ethereum/wiki/wiki/Ethereum-Natural-Specification-Format)

The code provided contains a file description comment block.

There is no versioning or date information in the source code.

MIT licensing has been stipulated against this code.

The code is tidy, well written and uses syntax and pattern appropriate for the compiler version.

### Compiler
Compiler pragma allows the contract to be compiled in Solidity version 0.4.11 or later which is the current stable release.

All contracts compile without error or warning in Solidity version 0.4.11.

### Deployment
This contract has been deployed and verified on the live chain at:
[0x2b09b52d42dfb4e0cba43f607dd272ea3fe1fb9f](https://etherscan.io/address/0x2b09b52d42dfb4e0cba43f607dd272ea3fe1fb9f#code)

The multisig to which funds will be sent during the fundraising is at:
[0x4938c291ab7e5e51198dfc210824da5d1bd759bf](https://etherscan.io/address/0x4938c291ab7e5e51198dfc210824da5d1bd759bf)
#### Deployment Constructor Parameters
Reading from the contract instance

Start Date: 1498741200
>  new Date(1498741200 * 1000).toGMTString()
"Thu, 29 Jun 2017 13:00:00 GMT"

End Date:	`1501074000`
> new Date(1501074000 * 1000).toGMTString()
"Wed, 26 Jul 2017 13:00:00 GMT"

Cap: `83333330000000000000000`
> 83333.33eth * 296 ~= 24,666,665 USD

Multisig: [`0x039704a4ecf78b0e1eef8f181a7838a0c68876ca`](https://etherscan.io/address/0x039704a4ecf78b0e1eef8f181a7838a0c68876ca)

Owner: [`0xb39c77767406ec8a147971736412b18bb0ec1619`](https://etherscan.io/address/0xb39c77767406ec8a147971736412b18bb0ec1619)

* **Issue** The ENDATE reported by the contract allows only 27 days for funding and not 28 days as per the white paper.

### Contract Analysis
#### SafeMath 
This library consists of underflow and overflow checked math functions `add()` and `sub()`.  They use well known and trusted bounds testing.

These functions are utilised in the later contracts using the `using/for` pattern to attach library functions to typed data.

No issues found.

#### Owned 
This contract provisions transferable ownership permission to a deriving contract.  It contains an `acceptOwnership()` function to prevent loss of contract control if an incorrect address is provided ownership 
##### State
`address public owner;`

This variable is appropriately typed and modified as public.

`address public newOwner;`

This variable is appropriately typed and modified as public.

`function Owned()`

Ownership is assigned during construction. {

`modifier onlyOwner`

This modifier is logically consistent.

`function transferOwnership(address _newOwner) onlyOwner`

This function initiates a transition of ownership.
 
`function acceptOwnership()`

This function finalised a transition of ownership by proof that the caller address, being equal to `newOwner` can control the contract.

* No issues found.

#### ERC20Token is Owned

This contract is an implementation of the well known ERC20 Token Standard.  This standard has a number of weakly defined aspects which are under active debate in the Ethereum community.  One point of debate is if the token transfer functions should throw on failure or return false.  The difference is that throwing will halt and revert a transaction, while `return false` will allow a caller to manage an exception.

The author of this contract has elected to use pattern `return false` on failure.  This requires an apparent reversion to mildly complex if/else conditional blocks rather than the contemporary keywords such as `require()` in order to avoid throwing.

`contract ERC20Token is Owned`

This contract in itself does not benefit from being owned.

* **Recommendation** Remove `Owner` as base contract.

`using SafeMath for uint;`

Proper use case for the `using/for` pattern to attach library function to the `uint` type.

##### State
`uint256 _totalSupply = 0;`

The author has elected to use a private state variable for `totalSupply` with an explicit public getter function. Private state with explicit getters can be useful when the getter needs to return a dynamic value.  An explicit getter is not necessary for this ICO contract, `_totalSupply` may be redefined as `uint public totalSupply;` and remove unnecessary code.

* **Consideration**: Define as `uint public totalSupply;` and remove explicit getter function `function totalSupply()`

`mapping(address => uint256) balances;`

As in the case with `totalSupply` this state variable can be defined as `public`.

* **Consideration**: Define as `mapping(address => uint256) public balanceOf;` and remove explicit getter function `function balanceOf(address _addr)`

`mapping(address => mapping (address => uint256)) allowed;`

As in the case with `totalSupply` this state variable can be defined as `public`. Additionally the getter `function allowance(address _owner, address _spender)` uses the parameter name of `_owner` which has the potential to be confused with the contract owner.

* **Consideration**: Define as `mapping(address => mapping (address => uint256)) allowance;`
and remove explicit getter function `function allowance(address _owner, address _spender)`
* **Recommendation**: Remove `Owner` as a base contract.

##### totalSupply
`function totalSupply() constant returns (uint256 totalSupply)`

* **Consideration** This getter is not required if recommendations are considered for state variable `_totalSupply`

##### balanceOf
`function balanceOf(address _owner) constant returns (uint256 balance)`

* **Consideration**  This getter is not required if recommendations are considered for state variable `balances`

##### transfer
```
function transfer(address _to, uint256 _amount) returns (bool success) {
        if (balances[msg.sender] >= _amount                // User has balance
            && _amount > 0                                 // Non-zero transfer
            && balances[_to] + _amount > balances[_to]     // Overflow check
        ) {
            balances[msg.sender] = balances[msg.sender].sub(_amount);
            balances[_to] = balances[_to].add(_amount);
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
```
This function is notable in that it appropriately uses the `SafeMath` library functions against `uint` types which presents cleaner more readable code.

The conditional logic blocks seem to be of obsolete patterns for the version of the compiler however the requirement of the function is to return `false` on a failed transfer rather than `throw` which would occur if `require()` were to be used.

There appears to be redundant overflow checking both in the entrance logic `balances[_to] + _amount > balances[_to]` and the SafeMath `balances[_to] = balances[_to].add(_amount);` however this is not the case as the entrance logic is used to return `false` while SafeMath is used to `throw`.

* No issues found
  
##### approve

* no issues found.

##### transferFrom
This function follow the same pattern as `transfer()` for the same reasons.

* no issues found

##### allowance

This getter is unnecessary if state variable `allowed` is redifined as `public allowance`

* **Consideration**:  Redefine `allowed` as `mapping(address => mapping (address => uint256)) allowance;` and remove explicit getter function `function allowance(address _owner, address _spender)`

##### Events
##### Transfer
`event Transfer(address indexed _from, address indexed _to, uint256 _value);`

* No issues found
##### Approval
`event Approval(address indexed _owner, address indexed _spender, uint256 _value);`

This event uses a parameter name `_owner` which my be confused with a contract owner.

* **Recommendation** Change parameter `_owner` to `_holder`

#### DaoCasinoToken
This is the BET token ICO contract which inherits ERC20Tokens and through it, Owned.  It is configured to accept funding from  29 June 2017 at 13:00.

##### DaoCasinoToken
`contract DaoCasinoToken is ERC20Token`

This contract derives `Owned` through `ERC20Token`.  As `ERC20Token` does not require ownership, this contract declaration would be more consistent by deriving `Owned` directly.

* **Recommendation** Remove `Owned` from `ERC20` and redefine `DaoCasinoToken` as `contract DaoCasinoToken is Owned, ERC20Token`.

#### State
##### symbol
`string public constant symbol = "BET";`

Is the ERC20 standard `symbol` identifier. Is constant. Is public.

* No issues found

##### name 
`string public constant name = "Dao.Casino";`

Is the ERC20 standard `name` identifier. Is constant. Is public.

* No issues found

##### decimals
`uint8 public constant decimals = 18;`

Is the optional ERC20 standard `decimals` identifier. Is constant. Is public.

* No issues found

##### STARTDATE
`uint256 public constant STARTDATE = 1498741200;`

This is the ICO start date in Unix time (units of seconds). The value assigned has been confirmed by the Javascript call `new Date("2017-06-29T13:00:00").getTime()/1000`

* No issues found.

##### STARTDATE
`uint256 public constant ENDDATE = STARTDATE + 28 days;`

This is the end date as a 28 day offset from the start date time. 

* No issues found.

##### CAP
`uint256 public constant CAP = 84417 ether;`

This is the funding cap which has been confirmed as approximately $25mm USD at an ETH/USD exchange rate of 296.1470 ETH/USD.

* This calculation does not take into account volitity in the ETH/USD exchange rate during the period of crowd funding.

* **Recommendation** An oracle providing the contract a live ETH/USD exchange rate would provide a more consistent fund cap.

***** multisig
`address public multisig = 0xa22AB8A9D641CE77e06D98b7D7065d324D3d6976;`

This is Dao.Casino's multisign address to which funds are transferred.  It should be declared a constant, however a bug is present in the Solidity 0.4.11 which incorrectly triggers a compiler warning.  This bug has been raised and acknowledged in [issue 2441](https://github.com/ethereum/solidity/issues/2441)

***** totalEthers
`uint256 public totalEthers;`

This state tracks the total ether received by the contract during funding.  Is public.

* No issues found;

#### Functions
##### Constructor
`function DaoCasinoToken(uint256 _start, uint256 _end, uint256 _cap, address _multisig)`

* No issues found;

##### buyPrice
`function buyPrice() constant returns (uint256)`

Function to return the momentry BET/ETH conversion rate during funding. Is public. Is constant.

* No issues found.

##### buyPriceAt
`function buyPriceAt(uint256 at) constant returns (uint256)`

Function to return the BET/ETH conversion rate at a given time from the conversion schedule. Is public. Is constant.

* No issues found.The rates are hardcoded as a lookup table 

##### Default function
`function () payable`

The default function passes all payments to `proxyPayment()` for processing.  Is payable.

* No issues found.

##### proxyPayment
`function proxyPayment(address participant) payable`

`proxyPayment()` allows for third party payers through the `participant` address. It throws on all occasions outside of the ICO funding timeframe, if the value sent is 0, or if the value sent would cause `totalEthers` to breach the funding cap.

`uint multisigTokens = tokens * 3 / 7;`
An additional 30% of tokens are created above the tokens awarded to the participant, which are awarded to the multisig address.

* No issues found

##### events TokensBought
`event TokensBought(address indexed buyer, uint256 ethers, 
        uint256 newEtherBalance, uint256 tokens, uint256 multisigTokens, 
        uint256 newTotalSupply, uint256 buyPrice);`

An appropriate event logging the necessary trust metrics.

* No issues found. 

##### addPrecommitment

function addPrecommitment(address participant, uint balance) onlyOwner {
        require(now < STARTDATE);
        require(balance > 0);
        balances[participant] = balances[participant].add(balance);
        _totalSupply = _totalSupply.add(balance);
        Transfer(0x0, participant, balance);
    }

A function to allow the owner to create pre-committed tokens to the contract prior to the fundraising.

No issues found.

##### transfer
`function transfer(address _to, uint _amount) returns (bool success)`

This function overloads the standard ERC20 `transfer() function with the additional condition that token transfers can only occur after either the funding period has completed or the funding cap has been reached. 

`require(now > ENDDATE || totalEthers == CAP);`

This logic is consistent.

* No issues found.

`function transferFrom(address _from, address _to, uint _amount)`

This function overloads the standard ERC20 `transferFrom() function with the additional condition that token transfers can only occur after either the funding period has completed or the funding cap has been reached. 

`require(now > ENDDATE || totalEthers == CAP);`

This logic is consistent.

* No issues found.

##### transferAnyERC20Token
`function transferAnyERC20Token(address tokenAddress, uint amount)`

This is an ancillary proxy function to allow the owner to transfer any ERC20 tokens that have been sent to the contract itself. 

* No issues found.



## Appendix
https://etherscan.io/address/0x2b09b52d42dfb4e0cba43f607dd272ea3fe1fb9f#code

```
pragma solidity ^0.4.11;

// ----------------------------------------------------------------------------
// Dao.Casino Crowdsale Token Contract (Under Consideration)
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017
// The MIT Licence (Under Consideration).
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Safe maths, borrowed from OpenZeppelin
// ----------------------------------------------------------------------------
library SafeMath {

    // ------------------------------------------------------------------------
    // Add a number to another number, checking for overflows
    // ------------------------------------------------------------------------
    function add(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }

    // ------------------------------------------------------------------------
    // Subtract a number from another number, checking for underflows
    // ------------------------------------------------------------------------
    function sub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        return a - b;
    }
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;
    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address _newOwner) onlyOwner {
        newOwner = _newOwner;
    }
 
    function acceptOwnership() {
        if (msg.sender == newOwner) {
            OwnershipTransferred(owner, newOwner);
            owner = newOwner;
        }
    }
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals
// https://github.com/ethereum/EIPs/issues/20
// ----------------------------------------------------------------------------
contract ERC20Token is Owned {
    using SafeMath for uint;

    // ------------------------------------------------------------------------
    // Total Supply
    // ------------------------------------------------------------------------
    uint256 _totalSupply = 0;

    // ------------------------------------------------------------------------
    // Balances for each account
    // ------------------------------------------------------------------------
    mapping(address => uint256) balances;

    // ------------------------------------------------------------------------
    // Owner of account approves the transfer of an amount to another account
    // ------------------------------------------------------------------------
    mapping(address => mapping (address => uint256)) allowed;

    // ------------------------------------------------------------------------
    // Get the total token supply
    // ------------------------------------------------------------------------
    function totalSupply() constant returns (uint256 totalSupply) {
        totalSupply = _totalSupply;
    }

    // ------------------------------------------------------------------------
    // Get the account balance of another account with address _owner
    // ------------------------------------------------------------------------
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from owner's account to another account
    // ------------------------------------------------------------------------
    function transfer(address _to, uint256 _amount) returns (bool success) {
        if (balances[msg.sender] >= _amount                // User has balance
            && _amount > 0                                 // Non-zero transfer
            && balances[_to] + _amount > balances[_to]     // Overflow check
        ) {
            balances[msg.sender] = balances[msg.sender].sub(_amount);
            balances[_to] = balances[_to].add(_amount);
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    // ------------------------------------------------------------------------
    // Allow _spender to withdraw from your account, multiple times, up to the
    // _value amount. If this function is called again it overwrites the
    // current allowance with _value.
    // ------------------------------------------------------------------------
    function approve(
        address _spender,
        uint256 _amount
    ) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    // ------------------------------------------------------------------------
    // Spender of tokens transfer an amount of tokens from the token owner's
    // balance to the spender's account. The owner of the tokens must already
    // have approve(...)-d this transfer
    // ------------------------------------------------------------------------
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool success) {
        if (balances[_from] >= _amount                  // From a/c has balance
            && allowed[_from][msg.sender] >= _amount    // Transfer approved
            && _amount > 0                              // Non-zero transfer
            && balances[_to] + _amount > balances[_to]  // Overflow check
        ) {
            balances[_from] = balances[_from].sub(_amount);
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
            balances[_to] = balances[_to].add(_amount);
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(
        address _owner, 
        address _spender
    ) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender,
        uint256 _value);
}


contract DaoCasinoToken is ERC20Token {

    // ------------------------------------------------------------------------
    // Token information
    // ------------------------------------------------------------------------
    string public constant symbol = "BET";
    string public constant name = "Dao.Casino";
    uint8 public constant decimals = 18;

    // Do not use `now` here
    uint256 public STARTDATE;
    uint256 public ENDDATE;

    // Cap USD 25mil @ 296.1470 ETH/USD
    uint256 public CAP;

    // Cannot have a constant address here - Solidity bug
    // https://github.com/ethereum/solidity/issues/2441
    address public multisig;

    function DaoCasinoToken(uint256 _start, uint256 _end, uint256 _cap, address _multisig) {
        STARTDATE = _start;
        ENDDATE   = _end;
        CAP       = _cap;
        multisig  = _multisig;
    }

    // > new Date("2017-06-29T13:00:00").getTime()/1000
    // 1498741200

    uint256 public totalEthers;

    // ------------------------------------------------------------------------
    // Tokens per ETH
    // Day  1    : 2,000 BET = 1 Ether
    // Days 2–14 : 1,800 BET = 1 Ether
    // Days 15–17: 1,700 BET = 1 Ether
    // Days 18–20: 1,600 BET = 1 Ether
    // Days 21–23: 1,500 BET = 1 Ether
    // Days 24–26: 1,400 BET = 1 Ether
    // Days 27–28: 1,300 BET = 1 Ether
    // ------------------------------------------------------------------------
    function buyPrice() constant returns (uint256) {
        return buyPriceAt(now);
    }

    function buyPriceAt(uint256 at) constant returns (uint256) {
        if (at < STARTDATE) {
            return 0;
        } else if (at < (STARTDATE + 1 days)) {
            return 2000;
        } else if (at < (STARTDATE + 15 days)) {
            return 1800;
        } else if (at < (STARTDATE + 18 days)) {
            return 1700;
        } else if (at < (STARTDATE + 21 days)) {
            return 1600;
        } else if (at < (STARTDATE + 24 days)) {
            return 1500;
        } else if (at < (STARTDATE + 27 days)) {
            return 1400;
        } else if (at <= ENDDATE) {
            return 1300;
        } else {
            return 0;
        }
    }


    // ------------------------------------------------------------------------
    // Buy tokens from the contract
    // ------------------------------------------------------------------------
    function () payable {
        proxyPayment(msg.sender);
    }


    // ------------------------------------------------------------------------
    // Exchanges can buy on behalf of participant
    // ------------------------------------------------------------------------
    function proxyPayment(address participant) payable {
        // No contributions before the start of the crowdsale
        require(now >= STARTDATE);
        // No contributions after the end of the crowdsale
        require(now <= ENDDATE);
        // No 0 contributions
        require(msg.value > 0);

        // Add ETH raised to total
        totalEthers = totalEthers.add(msg.value);
        // Cannot exceed cap
        require(totalEthers <= CAP);

        // What is the BET to ETH rate
        uint256 _buyPrice = buyPrice();

        // Calculate #BET - this is safe as _buyPrice is known
        // and msg.value is restricted to valid values
        uint tokens = msg.value * _buyPrice;

        // Check tokens > 0
        require(tokens > 0);
        // Compute tokens for foundation 30%
        // Number of tokens restricted so maths is safe
        uint multisigTokens = tokens * 3 / 7;

        // Add to total supply
        _totalSupply = _totalSupply.add(tokens);
        _totalSupply = _totalSupply.add(multisigTokens);

        // Add to balances
        balances[participant] = balances[participant].add(tokens);
        balances[multisig] = balances[multisig].add(multisigTokens);

        // Log events
        TokensBought(participant, msg.value, totalEthers, tokens,
            multisigTokens, _totalSupply, _buyPrice);
        Transfer(0x0, participant, tokens);
        Transfer(0x0, multisig, multisigTokens);

        // Move the funds to a safe wallet
        multisig.transfer(msg.value);
    }
    event TokensBought(address indexed buyer, uint256 ethers, 
        uint256 newEtherBalance, uint256 tokens, uint256 multisigTokens, 
        uint256 newTotalSupply, uint256 buyPrice);


    // ------------------------------------------------------------------------
    // Owner to add precommitment funding token balance before the crowdsale
    // commences
    // ------------------------------------------------------------------------
    function addPrecommitment(address participant, uint balance) onlyOwner {
        require(now < STARTDATE);
        require(balance > 0);
        balances[participant] = balances[participant].add(balance);
        _totalSupply = _totalSupply.add(balance);
        Transfer(0x0, participant, balance);
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from owner's account to another account, with a
    // check that the crowdsale is finalised
    // ------------------------------------------------------------------------
    function transfer(address _to, uint _amount) returns (bool success) {
        // Cannot transfer before crowdsale ends or cap reached
        require(now > ENDDATE || totalEthers == CAP);
        // Standard transfer
        return super.transfer(_to, _amount);
    }


    // ------------------------------------------------------------------------
    // Spender of tokens transfer an amount of tokens from the token owner's
    // balance to another account, with a check that the crowdsale is
    // finalised
    // ------------------------------------------------------------------------
    function transferFrom(address _from, address _to, uint _amount) 
        returns (bool success)
    {
        // Cannot transfer before crowdsale ends or cap reached
        require(now > ENDDATE || totalEthers == CAP);
        // Standard transferFrom
        return super.transferFrom(_from, _to, _amount);
    }


    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint amount)
      onlyOwner returns (bool success) 
    {
        return ERC20Token(tokenAddress).transfer(owner, amount);
    }
}
```
