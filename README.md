# Dao.Casino Presale Contract Audit (Work In Progress)

Website [https://dao.casino/](https://dao.casino/)

Jun 23 2017 - Source of original smart contracts from Ilya Tarutov:

* DaoCasinoICO [1.sol](contracts/1.sol) [https://gist.github.com/davy42/ee6f5152165a6eb487fb6f11153ac2ff](https://gist.github.com/davy42/ee6f5152165a6eb487fb6f11153ac2ff)
* TokenEmission [2.sol](contracts/2.sol) - [https://gist.github.com/davy42/e0416a14a6a2d1927a07d574d310f294](https://gist.github.com/davy42/e0416a14a6a2d1927a07d574d310f294)
  Note that the TokenEmission code is included in the DaoCasinoICO code.

Jun 26 2017 - Updated contracts from Ilya Tarutov:

1. ERC20 contract with emission
  * Github: [3.sol](contracts/3.sol) [https://github.com/airalab/core/blob/ffe24a8b9361fa7635adefb98f1ed8bdd8e2a775/contracts/token/TokenEmission.sol](https://github.com/airalab/core/blob/ffe24a8b9361fa7635adefb98f1ed8bdd8e2a775/contracts/token/TokenEmission.sol)
  * Compiled: [4.sol](contracts/4.sol) [https://gist.github.com/davy42/e0416a14a6a2d1927a07d574d310f294](https://gist.github.com/davy42/e0416a14a6a2d1927a07d574d310f294) (owner must be changed to crowdfunding contract).

2. Crowdfunding contract:
  * Github: [5.sol](contracts/5.sol) [https://github.com/airalab/dao.casino/blob/master/contracts/DaoCasinoICO.sol](https://github.com/airalab/dao.casino/blob/master/contracts/DaoCasinoICO.sol) 
  * Compiled version: [6.sol](contracts/6.sol) [https://gist.github.com/noxonsu/dd3ea77e3c077389c8b66e0ee358821a](https://gist.github.com/noxonsu/dd3ea77e3c077389c8b66e0ee358821a)

3. From "How to" https://github.com/airalab/dao.casino/issues/13

    1. deploy erc20 contract with arguments:

        * string _name = "dao.casino"
        * string _symbol = "bet"
        * uint8 _decimals = 18
        * uint _start_count = "{}" //amount of tokens sold on presale

    2. deploy DaoCasinoICO.sol

        * _fund Destination account address (our multisig)
        * _bounty Bounty token address (erc20 with emission function)
        * _reference Reference documentation link
        * _startBlock Funding start block number
        * _stopBlock Funding stop block nubmer
        * _minValue Minimal funded value in wei
        * _maxValue Maximal funded value in wei
        * _scale = 1; Bounty scaling factor by funded value
        * _startRatio = 1; not using
        * _reductionStep = 1; not using
        * _reductionValue = 1; not using

    3. execute function to ERC20 setOwner("address of crowdfunding contract");

    4. execute function to ERC20 setHammer("address of crowdfunding contract");

    done. now everybody can send Ether to crowdfunding address. But they not recive BETs before crowndfund ends.

    5. after crowdsale ends users can execute getMyBounty()

    6. or we can bulk execute getBounty(address _participant) where _participant is one by one all our participants.

The contracts being audited are in [DaoCasinoICO.sol](contracts/DaoCasinoICO.sol) which is the same as [6.sol](contracts/6.sol).

Comments on the source code can be found in [DaoCasinoICO.md](DaoCasinoICO.md).

**NOTE** that the convention for token symbols and names is for uppercase characters to be used in the symbol ("BET") and for title case characters to be used in the name ("DAO.Casino") - refer to the list of ERC20 tokens at [https://cryptoderivatives.market/](https://cryptoderivatives.market/).

<br />

<hr />

# Recommendation

* MEDIUM IMPORTANCE - As found by Darryl Morris, `Token.totalSupply` will hide `ERC20.totalSupply` and should be removed.

<br />

<br />

Enjoy. (c) Dao.Casino and BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.