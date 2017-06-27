# Dao.Casino Presale Contract Audit (Work In Progress)

Bok Consulting Pty Ltd has been retained by [Dao.Casino](https://dao.casino/) to audit the Ethereum contract to be used in Dao.Casino's upcoming crowdsale.

Bok Consulting Pty Ltd commissioned an independent code review by Darryl Morris which can be found at [DarrylMorris-Audit-DaoCasinoICO.md](DarrylMorris-Audit-DaoCasinoICO.md). 
When reading Darryl's report, please take into account that he did not know there was no minimum funding level for the crowdsale.

From [DAO.Casino Announces Terms of its Token Sale to be held June 29](https://medium.com/@dao.casino/dao-casino-announces-terms-of-its-token-sale-to-be-held-june-29-5125375f4aeb), 
this crowdsale has the following parameters:

<kbd><img src="images/Dao.CasinoCrowdsaleParameters-20170628-022847.png" /></kbd>

<br />

<hr />

## Table Of Contents

* [Summary](#summary)
  * [Crowdsale Source Code](#crowdsale-source-code)
  * [Trustlessness?](#trustlessness)
  * [No Security Risk Identifier Yet](#no-security-risk-identified-yet)
  * [Tokens](#tokens)
  * [Vesting?](#vesting)
  * [Due Diligence Required](#due-diligence-required)
  * [Recommendation](#recommendation)
* [Scope](#scope)
* [Limitations](#limitations)
* [Due Diligence](#due-diligence)
* [Risks](#risks)
* [Recommendations](#recommendations)
* [TODO](#todo)
* [Source Code Audited](#source-code-audited)

<br />

<hr />

## Summary

### Crowdsale Source Code
The **DaoCasinoICO** and **TokenEmission** contracts are well formatted and set out, but there is an unnecessary convoluted relationship between these two contracts.
There is also some unnecessary overloading of data (`totalSupply`), modifiers (`onlySuccess`) and functions (`bountyValue(...)`, `withdraw()`) that makes understanding 
these contracts a little bit harder.

### Trustlessness?
These contracts were not designed with trustlessness as a primary aim. This is highlighted by the ability to premine tokens after deployment of **TokenEmission** and 
before **TokenEmission** is linked to **DaoCasinoICO**, and the inclusion of the refund facility (but inactive because of the lack of a minimum funding goal) while at
the same time allowing the owners to withdraw funds from the **DaoCasinoICO** using the `withdrawEth()` function.

Additionally the parameters used in the deployment of this contract will need to be confirmed.

### No Security Risk Identified Yet
No serious security risk has been identified in the contracts yet. It is however recommended that the owner of the contracts frequently drain the ethers from the 
**DaoCasinoICO** contract into a more secure external `fund` wallet using the `withdrawEth()` function. This is to avoid **DaoCasinoICO** from being an attractive attack target.

### Tokens
These contracts could have been designed to deliver the tokens directly after participants send their ETH, thus keeping participants wondering what number of tokens they
"bought" with their ethers. Instead participants will be able to query the non-standard `bounties` field (when the source code is verified on EtherScan) to determine the 
number of tokens they have bought.

### Vesting?
From the blog post [DAO.Casino Announces Terms of its Token Sale to be held June 29](https://medium.com/@dao.casino/dao-casino-announces-terms-of-its-token-sale-to-be-held-june-29-5125375f4aeb):

<kbd><img src="images/Dao.CasinoCrowdsaleVesting-20170628-161331.png" /></kbd>

Note that there is **NO** vesting built into any of the **DaoCasinoICO** or **TokenEmission** contracts audited.

### Due Diligence Required
As always, potential participants should perform their [due diligence](#due-diligence) before investing into any crowdsale, including this one.

### Recommendation
The crowdsale should be delayed until the vesting functionality is written into the crowdsale contracts. Other issues identified in this report should also be addressed at the same time.
Or that the blog post be updated clearly stating that there is no vesting built into the contracts.

<br />

<hr />

## Scope
This audit is into the technical aspects of the crowdsale contracts. The primary aim of this audit is to ensure that funds contributed to these contracts are not easily attacked or stolen by third parties. 
The secondary aim of this audit is that ensure the coded algorithms work as expected. This audit does not guarantee that that the code is bugfree, but intends to highlight any areas of weaknesses.

<br />

<hr />

## Limitations
This audit makes no statements or warranties about the viability of the Dao.Casino's business proposition, the individuals involved in this business or the regulatory regime for the business model.

<br />

<hr />

## Due Diligence
As always, potential participants in any crowdsale are encouraged to perform their due diligence on the business proposition before funding the crowdsale.

Potential participants are also encouraged to only send their funds to the official crowdsale Ethereum address, as scammers have been publishing phishing address in the Slacks, Subreddits, Twitter and other communication channels. 
Potential participants should also confirm that the verified source code on EtherScan.io for the published crowdsale address matches the audited source code audited, and that the deployment parameters are correctly set.

Potential participants should note that there is no minimum funding goal in this crowdsale. The `Crowdfunding.refund()` function that **DaoCasinoICO** inherits will be ineffective in this crowdsale due to the lack of a minimum funding goal. The owner of the contracts also has the ability 
to withdraw any funds using the `DaoCasinoICO.withdrawEth()` function at any time during the crowdsale, rendering the refund functionality ineffective IF a minimum funding goal was set.

<br />

<hr />

## Risks

The primary risk of crowdfunding contracts is that the high value of ethers held by a newly designed un-battle tested contract is a target for attack.

While this crowdsale contract will accumulate ethers during the crowdsale. The owner of the contracts is advised to periodically withdraw ETH from the crowdsale contracts to reduce the risk of attacks on the contract.

If there is a logic error in the calculations


<br />

<hr />

## Potential Vulnerabilities



<br />

<hr />

## Recommendations

* **HIGH IMPORTANCE** - The crowdsale should be delayed until the crowdsale contracts are re-written to reflect the offering described in the [blog post](https://medium.com/@dao.casino/dao-casino-announces-terms-of-its-token-sale-to-be-held-june-29-5125375f4aeb), 
and this is primarily the vesting of the tokens. Or that the blog post be updated clearly stating that there is no vesting built into the contracts.

* LOW IMPORTANCE - As found by Darryl Morris, `Token.totalSupply` will hide `ERC20.totalSupply` and should be removed. This variable is unused in the **ERC20** contract, will always be set to 0. The **TokenEmission** version of `totalSupply` will be used to record the total supply of tokens

* LOW IMPORTANCE - Add a function for the owner to transfer out any other ERC20 tokens from the TokenEmission contract - see the example [`transferAnyERC20Token(...)`](https://github.com/openanx/OpenANXToken/blob/master/contracts/OpenANXToken.sol#L451-L458)

* LOW IMPORTANCE - The relationship between the **TokenEmission** contract and the **DaoCasinoICO** contract requires that the **TokenEmission** `owner` and `hammer` variables point to the **DaoCasinoICO** contract address. If the `owner` variable is not correctly set, the **TokenEmission** contract will fail to create the tokens for the accounts sending ETH to the **DaoCasinoICO** contract 

* NOTE - When an account sends ETH to the **DaoCasinoICO** contract, the tokens are created in the **TokenEmission** contract, but assigned to the address of the **DaoCasinoICO** in the **TokenEmission** contract. The participant's account, or the owner of the contracts will have to call `getBounty(...)` for the tokens to be transferred to the participant's account, and this can only be executed if the crowdsale is successful

* NOTE - For the crowdsale `onlySuccess` modifier to indicate a successful status, the funding has to **EXACTLY** match the crowdsale maximum cap in ETH (as `totalFunded == config.maxValue` in `DaoCasinoICO.onlySuccess`), or the current time has to be past the crowdsale closing date. If the funding is close to the cap, anyone including the owner will have the ability to top up the crowdsale funds for this match to occur for this crowdsale to end earlier than the intended closing date 

* The **DaoCasinoICO** contract has several constructor parameters that are unused in any calculations: `_reference`, `_startRatio`, `_reductionStep` and `_reductionValue`. Ideally these should be removed to make the code more easily readable

* The **DaoCasinoICO** contract has several functions and modifiers that overload the **Crowdfunding** contract functions and modifiers: `bountyValue(...)`, `onlySuccess`, `withdraw()`. Ideally these should be removed from the **Crowdfunding** contract to make the code more easily readable

* The **TokenEmission** contract should implement the `function () payable { throw; }` function to reject any ETH being sent to it, as there will be no ability to withdraw these ETH from this token contract

* LOW IMPORTANCE - There is no easy way to work out whether these contracts are computing the correct number of tokens for the ETH that participants send. It is easy to log an event that will help keep track of the calculations. Example [`TokensBought(...)`](https://github.com/openanx/OpenANXToken/blob/master/contracts/OpenANXToken.sol#L260-L261) that can easily be extracted to create a near-realtime [report](https://github.com/openanx/OpenANXToken/blob/master/scripts/TokensBought_20170625_015900.tsv)
 
<br />

## TODO

* Overview comments on the source code

* Overflow

* Underflow

* Logic hijacking

* This contract uses block numbers to determine the start, end and token rate changed in the crowdsale. As these block numbers are variable and increasing, only approximate times can be published for these dates. Expect some of the transactions to throw errors due to unexpected block numbers.

* An unlimited number of tokens can be created during the deployment of **TokenEmission**

* As there are quite a parameters that interlink the **DaoCasinoICO* and **TokenEmission** contracts together, it is recommended that a script be created to easily display these parameters and check for correctness 

<br />

<hr />

## Source Code Audited

A version of the audited source code with my commentary can be found in [DaoCasinoICO.md](DaoCasinoICO.md).

This is based on the source code in [contracts/DaoCasinoICO.sol](contracts/DaoCasinoICO.sol) that was tested, 
and is the same source code as listed in [6.sol](contracts/6.sol) below.

On Jun 23 2017 Ilya Tarutov provided links to the first version of the source code:

> * DaoCasinoICO [1.sol](contracts/1.sol) [https://gist.github.com/davy42/ee6f5152165a6eb487fb6f11153ac2ff](https://gist.github.com/davy42/ee6f5152165a6eb487fb6f11153ac2ff)
> * TokenEmission [2.sol](contracts/2.sol) - [https://gist.github.com/davy42/e0416a14a6a2d1927a07d574d310f294](https://gist.github.com/davy42/e0416a14a6a2d1927a07d574d310f294)
  Note that the TokenEmission code is included in the DaoCasinoICO code.

On Jun 26 2017 Ilya Tarutov provided links to the updated version of the source code:

> 1. ERC20 contract with emission
>   * Github: [3.sol](contracts/3.sol) [https://github.com/airalab/core/blob/ffe24a8b9361fa7635adefb98f1ed8bdd8e2a775/contracts/token/TokenEmission.sol](https://github.com/airalab/core/blob/ffe24a8b9361fa7635adefb98f1ed8bdd8e2a775/contracts/token/TokenEmission.sol)
>   * Compiled: [4.sol](contracts/4.sol) [https://gist.github.com/davy42/e0416a14a6a2d1927a07d574d310f294](https://gist.github.com/davy42/e0416a14a6a2d1927a07d574d310f294) (owner must be changed to crowdfunding contract).
>
> 2. Crowdfunding contract:
>   * Github: [5.sol](contracts/5.sol) [https://github.com/airalab/dao.casino/blob/master/contracts/DaoCasinoICO.sol](https://github.com/airalab/dao.casino/blob/master/contracts/DaoCasinoICO.sol) 
>   * Compiled version: [6.sol](contracts/6.sol) [https://gist.github.com/noxonsu/dd3ea77e3c077389c8b66e0ee358821a](https://gist.github.com/noxonsu/dd3ea77e3c077389c8b66e0ee358821a)
>
> 3. From "How to" https://github.com/airalab/dao.casino/issues/13
> 
>     1. deploy erc20 contract with arguments:
> 
>         * string _name = "dao.casino"
>         * string _symbol = "bet"
>         * uint8 _decimals = 18
>         * uint _start_count = "{}" //amount of tokens sold on presale
> 
>     2. deploy DaoCasinoICO.sol
> 
>         * _fund Destination account address (our multisig)
>         * _bounty Bounty token address (erc20 with emission function)
>         * _reference Reference documentation link
>         * _startBlock Funding start block number
>         * _stopBlock Funding stop block nubmer
>         * _minValue Minimal funded value in wei
>         * _maxValue Maximal funded value in wei
>         * _scale = 1; Bounty scaling factor by funded value
>         * _startRatio = 1; not using
>         * _reductionStep = 1; not using
>         * _reductionValue = 1; not using
> 
>     3. execute function to ERC20 setOwner("address of crowdfunding contract");
> 
>     4. execute function to ERC20 setHammer("address of crowdfunding contract");
> 
>     done. now everybody can send Ether to crowdfunding address. But they not recive BETs before crowndfund ends.
> 
>     5. after crowdsale ends users can execute getMyBounty()
> 
>     6. or we can bulk execute getBounty(address _participant) where _participant is one by one all our participants.

**NOTE** In 3 above, the "erc20" contract does not refer to the **ERC20** contract in the source code as this contract does not implement the functions to operate correctly. 
The deployed "erc20" token contract required for the **DaoCasinoICO** contract to work correctly is the **TokenEmission** contract.

<br />

<br />

Enjoy. (c) Dao.Casino and BokkyPooBah / Bok Consulting Pty Ltd for Dao.Casino Jun 28 2017. The MIT Licence.