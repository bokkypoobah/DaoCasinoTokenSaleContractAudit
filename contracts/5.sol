pragma solidity ^0.4.11;

import 'foundation/Crowdfunding.sol';

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
