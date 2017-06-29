#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Get Details For The Dao.Casino token contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

# Set below if you don't want to use IPC
# GETHATTACHPOINT=rpc:http://localhost:8545
# GETHATTACHPOINT=rpc:http://localhost:8646

DATE=`date "+%Y%m%d_%H%M%S"`
# DATE=`date "+%Y%m%d"`
echo "Date: $DATE"

TEMPFILE=Temp_$DATE.txt
MAINFILE=Main_$DATE.txt
TOKENSBOUGHTFILE=TokensBought_$DATE.tsv
TRANSFERFILE=Transfers_$DATE.tsv

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee $TEMPFILE

var tokenAddress="0x2b09b52d42dfb4e0cba43f607dd272ea3fe1fb9f";
var tokenDeploymentBlock=3945138;
// DEV var tokenAddress="0xe6ada9beed6e24be4c0259383db61b52bfca85f3";
// DEV var tokenDeploymentBlock=3733;

var tokenAbi=[{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_amount","type":"uint256"}],"name":"approve","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalEthers","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"totalSupply","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"ENDDATE","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_amount","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"participant","type":"address"},{"name":"balance","type":"uint256"}],"name":"addPrecommitment","outputs":[],"payable":false,"type":"function"}, \
{"constant":true,"inputs":[{"name":"at","type":"uint256"}],"name":"buyPriceAt","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"multisig","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"acceptOwnership","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"STARTDATE","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"buyPrice","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_amount","type":"uint256"}], \
"name":"transfer","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"newOwner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"tokenAddress","type":"address"},{"name":"amount","type":"uint256"}],"name":"transferAnyERC20Token","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"CAP","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"participant","type":"address"}],"name":"proxyPayment","outputs":[],"payable":true,"type":"function"},{"inputs":[{"name":"_start","type":"uint256"},{"name":"_end","type":"uint256"},{"name":"_cap","type":"uint256"},{"name":"_multisig","type":"address"}], \
"payable":false,"type":"constructor"},{"payable":true,"type":"fallback"},{"anonymous":false,"inputs":[{"indexed":true,"name":"buyer","type":"address"},{"indexed":false,"name":"ethers","type":"uint256"},{"indexed":false,"name":"newEtherBalance","type":"uint256"},{"indexed":false,"name":"tokens","type":"uint256"},{"indexed":false,"name":"multisigTokens","type":"uint256"},{"indexed":false,"name":"newTotalSupply","type":"uint256"},{"indexed":false,"name":"buyPrice","type":"uint256"}],"name":"TokensBought","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_owner","type":"address"},{"indexed":true,"name":"_spender","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"}],"name":"OwnershipTransferred","type":"event"}];

var contract = eth.contract(tokenAbi).at(tokenAddress);

var multisig = contract.multisig();
console.log("MAIN: token.address=" + tokenAddress);
console.log("MAIN: token.multisig=" + multisig);
console.log("MAIN: token.deploymentBlock=" + tokenDeploymentBlock);
var multisigBalanceAtTokenDeploymentBlock = eth.getBalance(multisig, tokenDeploymentBlock);
console.log("MAIN: token.multisigBalanceAtTokenDeploymentBlock=" + multisigBalanceAtTokenDeploymentBlock.shift(-18));
console.log("MAIN: token.owner=" + contract.owner());
console.log("MAIN: token.newOwner=" + contract.newOwner());

var decimals = contract.decimals();
console.log("MAIN: token.symbol=" + contract.symbol());
console.log("MAIN: token.name=" + contract.name());
console.log("MAIN: token.decimals=" + decimals);
console.log("MAIN: token.totalSupply=" + contract.totalSupply().shift(-decimals));
console.log("MAIN: token.totalEthers=" + contract.totalEthers().shift(-18));
console.log("MAIN: token.CAP=" + contract.CAP().shift(-decimals));
var currentTime = new Date();
console.log("MAIN: currentTime=" + currentTime / 1000 + " " + currentTime.toUTCString() + " / " + currentTime.toGMTString());
var startDate = contract.STARTDATE();
console.log("MAIN: token.STARTDATE=" + startDate + " " + new Date(startDate * 1000).toUTCString()  + " / " + new Date(startDate * 1000).toGMTString());
var endDate = contract.ENDDATE();
console.log("MAIN: token.ENDDATE=" + endDate + " " + new Date(endDate * 1000).toUTCString() + " / " + new Date(endDate * 1000).toGMTString());
console.log("MAIN: token.timeToStart=" + (new Date(startDate*1000).getTime() - currentTime.getTime())/1000/60/50 + " hours"); 

for (var day = parseInt(startDate) - parseInt(60*60*24*2); day <= parseInt(endDate) + parseInt(60*60*24*2); day = parseInt(day) + parseInt(60*60*24)) {
  var secondBefore = parseInt(day) - 1;
  var rateSecondBefore = contract.buyPriceAt(secondBefore);
  var secondAfter = parseInt(day) + 1;
  var rateSecondAfter = contract.buyPriceAt(secondAfter);
  console.log("MAIN: day=" + day + " " + new Date(day*1000).toGMTString() + " before=" + rateSecondBefore + " after=" + rateSecondAfter);
}

var latestBlock = eth.blockNumber;
var i;

var ownershipTransferredEvents = contract.OwnershipTransferred({}, { fromBlock: tokenDeploymentBlock, toBlock: latestBlock });
i = 0;
ownershipTransferredEvents.watch(function (error, result) {
  console.log("MAIN: OwnershipTransferred Event " + i++ + ": from=" + result.args._from + " to=" + result.args._to + " " + result.blockNumber);
});
ownershipTransferredEvents.stopWatching();

var tokensBoughtEvents = contract.TokensBought({}, { fromBlock: tokenDeploymentBlock, toBlock: latestBlock });
i = 0;
var lastBlockNumber = 0;
var lastMultisigBalance = 0;
var lastTimestamp = 0;
console.log("TOKENSBOUGHT: No\tBuyer\tEthers\tTokens\tMultisigTokens\tTokenBalance\tTokensPerKEther\tTxIndex\tTxHash\tBlock\tTimestamp\tEtherBalance\tMultisigEtherBalance");
tokensBoughtEvents.watch(function (error, result) {
  if (result.blockNumber != lastBlockNumber) {
    lastTimestamp = eth.getBlock(result.blockNumber).timestamp;
    lastMultisigBalance = eth.getBalance(multisig, result.blockNumber).sub(multisigBalanceAtTokenDeploymentBlock);
    lastBlockNumber = eth.blockNumber;
  }
  console.log("TOKENSBOUGHT: " + i++ + "\t" + result.args.buyer + "\t" + web3.fromWei(result.args.ethers, "ether") + 
    "\t" + result.args.tokens.shift(-decimals) + "\t" + result.args.multisigTokens.shift(-decimals) + "\t" + result.args.newTotalSupply.shift(-decimals) + 
    "\t" + result.args.buyPrice + "\t" + result.transactionIndex + "\t" + result.transactionHash + "\t" + result.blockNumber + "\t" + lastTimestamp + 
    "\t" + web3.fromWei(result.args.newEtherBalance, "ether") + "\t" + web3.fromWei(lastMultisigBalance, "ether"));
});
tokensBoughtEvents.stopWatching();

var approvalEvents = contract.Approval({}, { fromBlock: tokenDeploymentBlock, toBlock: latestBlock });
i = 0;
approvalEvents.watch(function (error, result) {
  console.log("MAIN: Approval Event " + i++ + ": owner=" + result.args._owner + " spender=" + result.args._spender + " " +
    result.args._value.shift(-decimals) + " block=" + result.blockNumber);
});
approvalEvents.stopWatching();

var transferEvents = contract.Transfer({}, { fromBlock: tokenDeploymentBlock, toBlock: latestBlock });
i = 0;
var totalTokens = new BigNumber(0);
console.log("TRANSFER: No\tFrom\tTo\tTokens\tTokenBalance\tBlock\tTxIndex\tTxHash");
transferEvents.watch(function (error, result) {
  // console.log("TRANSFER: " + JSON.stringify(result));
  totalTokens = totalTokens.add(result.args._value);
  console.log("TRANSFER: " + i++ + "\t" + result.args._from + "\t" + result.args._to + "\t" + result.args._value.shift(-decimals) + 
    "\t" + totalTokens.shift(-decimals) + "\t" + result.blockNumber + "\t" + result.transactionIndex + "\t" + result.transactionHash);
});
transferEvents.stopWatching();

EOF

grep "MAIN: " $TEMPFILE | sed "s/MAIN: //" > $MAINFILE
grep "TOKENSBOUGHT: " $TEMPFILE | sed "s/TOKENSBOUGHT: //" > $TOKENSBOUGHTFILE
grep "TRANSFER: " $TEMPFILE | sed "s/TRANSFER: //" > $TRANSFERFILE
