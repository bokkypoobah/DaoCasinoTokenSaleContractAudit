#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`

DAOCASINOTOKENSOL=`grep ^DAOCASINOTOKENSOL= settings.txt | sed "s/^.*=//"`
DAOCASINOTOKENTEMPSOL=`grep ^DAOCASINOTOKENTEMPSOL= settings.txt | sed "s/^.*=//"`
DAOCASINOTOKENJS=`grep ^DAOCASINOTOKENJS= settings.txt | sed "s/^.*=//"`

DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST2OUTPUT=`grep ^TEST2OUTPUT= settings.txt | sed "s/^.*=//"`
TEST2RESULTS=`grep ^TEST2RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

BLOCKSINDAY=10

#if [ "$MODE" == "dev" ]; then
  # Start time now
  #  STARTTIME=`echo "$CURRENTTIME" | bc`
#else
  # Start time 1m 10s in the future
  # STARTTIME=`echo "$CURRENTTIME+75" | bc`
#fi
STARTTIME=`echo "$CURRENTTIME" | bc`
STARTTIME_S=`date -r $STARTTIME -u`
ENDTIME=`echo "$CURRENTTIME+60*30" | bc`
ENDTIME_S=`date -r $ENDTIME -u`

printf "MODE                  = '$MODE'\n"
printf "GETHATTACHPOINT       = '$GETHATTACHPOINT'\n"
printf "PASSWORD              = '$PASSWORD'\n"
printf "DAOCASINOTOKENSOL     = '$DAOCASINOTOKENSOL'\n"
printf "DAOCASINOTOKENTEMPSOL = '$DAOCASINOTOKENTEMPSOL'\n"
printf "DAOCASINOTOKENJS      = '$DAOCASINOTOKENJS'\n"
printf "DEPLOYMENTDATA        = '$DEPLOYMENTDATA'\n"
printf "INCLUDEJS             = '$INCLUDEJS'\n"
printf "TEST2OUTPUT           = '$TEST2OUTPUT'\n"
printf "TEST2RESULTS          = '$TEST2RESULTS'\n"
printf "CURRENTTIME           = '$CURRENTTIME' '$CURRENTTIMES'\n"
printf "STARTTIME             = '$STARTTIME' '$STARTTIME_S'\n"
printf "ENDTIME               = '$ENDTIME' '$ENDTIME_S'\n"

# Make copy of SOL file and modify start and end times ---
`cp $DAOCASINOTOKENSOL $DAOCASINOTOKENTEMPSOL`

# --- Modify dates ---
`perl -pi -e "s/STARTDATE \= 1498741200;.*$/STARTDATE \= $STARTTIME; \/\/ $STARTTIME_S/" $DAOCASINOTOKENTEMPSOL`
`perl -pi -e "s/ENDDATE \= STARTDATE \+ 28 days;.*$/ENDDATE \= STARTDATE \+ 600 minutes;/" $DAOCASINOTOKENTEMPSOL`
`perl -pi -e "s/CAP \= 84417 ether;.*$/CAP \= 100 ether;/" $DAOCASINOTOKENTEMPSOL`

DIFFS1=`diff $DAOCASINOTOKENSOL $DAOCASINOTOKENTEMPSOL`
echo "--- Differences $DAOCASINOTOKENSOL $DAOCASINOTOKENTEMPSOL ---"
echo "$DIFFS1"

echo "var dctOutput=`solc --optimize --combined-json abi,bin,interface $DAOCASINOTOKENTEMPSOL`;" > $DAOCASINOTOKENJS


geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee $TEST2OUTPUT
loadScript("$DAOCASINOTOKENJS");
loadScript("functions.js");

var dctAbi = JSON.parse(dctOutput.contracts["$DAOCASINOTOKENTEMPSOL:DaoCasinoToken"].abi);
var dctBin = "0x" + dctOutput.contracts["$DAOCASINOTOKENTEMPSOL:DaoCasinoToken"].bin;

console.log("DATA: dctAbi=" + JSON.stringify(dctAbi));

unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var dctMessage = "Deploy Token Contract";
console.log("RESULT: " + teMessage);
var dctContract = web3.eth.contract(dctAbi);
console.log(JSON.stringify(dctContract));
var dctTx = null;
var dctAddress = null;

var dct = dctContract.new({from: contractOwnerAccount, data: dctBin, gas: 6000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        dctTx = contract.transactionHash;
      } else {
        dctAddress = contract.address;
        addAccount(dctAddress, "BET Token Contract");
        addDctContractAddressAndAbi(dctAddress, dctAbi);
        addTokenContractAddressAndAbi(dctAddress, dctAbi);
        console.log("DATA: dctAddress=" + dctAddress);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

printTxData("dctAddress=" + dctAddress, dctTx);
printBalances();
failIfGasEqualsGasUsed(dctTx, dctMessage);
printDctContractDetails();
console.log("RESULT: ");


if (false) {
// -----------------------------------------------------------------------------
var preCommitMessage = "Add PreCommitments - 1000 BET Acc3, 10000 BET Acc4";
console.log("RESULT: " + preCommitMessage);
var preCommit1Tx = dct.addPrecommitment(preCommitAccount1, "1000000000000000000000", {from: contractOwnerAccount, gas: 400000});
var preCommit2Tx = dct.addPrecommitment(preCommitAccount2, "10000000000000000000000", {from: contractOwnerAccount, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("preCommit1Tx", preCommit1Tx);
printTxData("preCommit2Tx", preCommit2Tx);
printBalances();
failIfGasEqualsGasUsed(preCommit1Tx, preCommitMessage);
failIfGasEqualsGasUsed(preCommit2Tx, preCommitMessage);
printDctContractDetails();
console.log("RESULT: ");
}


if (false) {
// -----------------------------------------------------------------------------
// Wait for crowdsale start
// -----------------------------------------------------------------------------
var startTime = dct.STARTDATE();
var startTimeDate = new Date(startTime * 1000);
console.log("RESULT: Waiting until startTime at " + startTime + " " + startTimeDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= startTimeDate.getTime()) {
}
console.log("RESULT: Waited until startTime at " + startTime + " " + startTimeDate +
  " currentDate=" + new Date());
}

for (var gas = 80000; gas < 400000; gas += 10000) {
  var testGasMessage = "--- Testing gas = " + gas + " ---";
  console.log("RESULT: " + testGasMessage);
  var sendTx = null;
  try {
    sendTx = eth.sendTransaction({from: account5, to: dctAddress, gas: gas, value: web3.toWei("1", "ether")});
  } catch (e) {
  } 
  if (sendTx != null) {
    while (txpool.status.pending > 0) {
    }
    printTxData("sendTx", sendTx);
    printBalances();
    failIfGasEqualsGasUsed(sendTx, testGasMessage);
    printDctContractDetails();
    if (!gasEqualsGasUsed(sendTx)) {
      break;
    }
  }
}

exit;
var validContribution1Message = "Send Valid Contribution - 7 ETH From Account5, 14 ETH From Account6";
console.log("RESULT: " + validContribution1Message);
var sendValidContribution1Tx = eth.sendTransaction({from: account5, to: dctAddress, gas: 400000, value: web3.toWei("7", "ether")});
var sendValidContribution2Tx = eth.sendTransaction({from: account6, to: dctAddress, gas: 400000, value: web3.toWei("14", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("sendValidContribution1Tx", sendValidContribution1Tx);
printTxData("sendValidContribution2Tx", sendValidContribution2Tx);
printBalances();
failIfGasEqualsGasUsed(sendValidContribution1Tx, validContribution1Message);
failIfGasEqualsGasUsed(sendValidContribution2Tx, validContribution1Message);
printDctContractDetails();
console.log("RESULT: ");



if (false) {
// -----------------------------------------------------------------------------
var validContribution1Message = "Send Valid Contribution - 7 ETH From Account5, 14 ETH From Account6";
console.log("RESULT: " + validContribution1Message);
var sendValidContribution1Tx = eth.sendTransaction({from: account5, to: dctAddress, gas: 400000, value: web3.toWei("7", "ether")});
var sendValidContribution2Tx = eth.sendTransaction({from: account6, to: dctAddress, gas: 400000, value: web3.toWei("14", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("sendValidContribution1Tx", sendValidContribution1Tx);
printTxData("sendValidContribution2Tx", sendValidContribution2Tx);
printBalances();
failIfGasEqualsGasUsed(sendValidContribution1Tx, validContribution1Message);
failIfGasEqualsGasUsed(sendValidContribution2Tx, validContribution1Message);
printDctContractDetails();
console.log("RESULT: ");
}


if (false) {
// -----------------------------------------------------------------------------
var cannotTransferMessage = "Cannot Move Tokens Without Finalisation";
console.log("RESULT: " + cannotTransferMessage);
var cannotTransfer1Tx = dct.transfer(account7, "1000000000000", {from: account5, gas: 100000});
var cannotTransfer2Tx = dct.approve(account8,  "30000000000000000", {from: account6, gas: 100000});
while (txpool.status.pending > 0) {
}
var cannotTransfer3Tx = dct.transferFrom(account6, account8, "30000000000000000", {from: account8, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("cannotTransfer1Tx", cannotTransfer1Tx);
printTxData("cannotTransfer2Tx", cannotTransfer2Tx);
printTxData("cannotTransfer3Tx", cannotTransfer3Tx);
printBalances();
passIfGasEqualsGasUsed(cannotTransfer1Tx, cannotTransferMessage + " - transfer 0.000001 BET ac5 -> ac7. CHECK no movement");
failIfGasEqualsGasUsed(cannotTransfer2Tx, cannotTransferMessage + " - approve 0.03 BET ac6 -> ac8");
passIfGasEqualsGasUsed(cannotTransfer3Tx, cannotTransferMessage + " - transferFrom 0.03 BET ac6 -> ac8. CHECK no movement");
printDctContractDetails();
console.log("RESULT: ");
}


if (false) {
// -----------------------------------------------------------------------------
var validContribution2Message = "Send Valid Contribution - 79 ETH From Account5";
console.log("RESULT: " + validContribution2Message);
var sendValidContribution3Tx = eth.sendTransaction({from: account5, to: dctAddress, gas: 400000, value: web3.toWei("79", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("sendValidContribution3Tx", sendValidContribution3Tx);
printBalances();
failIfGasEqualsGasUsed(sendValidContribution3Tx, validContribution2Message);
printDctContractDetails();
console.log("RESULT: ");
}


if (false) {
// -----------------------------------------------------------------------------
var invalidContribution3Message = "Send Invalid Contribution - 1 ETH From Account7 - Cap Reached";
console.log("RESULT: " + invalidContribution3Message);
var sendInvalidContribution1Tx = eth.sendTransaction({from: account7, to: dctAddress, gas: 400000, value: web3.toWei("1", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("sendInvalidContribution1Tx", sendInvalidContribution1Tx);
printBalances();
passIfGasEqualsGasUsed(sendInvalidContribution1Tx, invalidContribution3Message);
printDctContractDetails();
console.log("RESULT: ");
}


if (false) {
// -----------------------------------------------------------------------------
var canTransferMessage = "Can Move Tokens After Cap Reached";
console.log("RESULT: " + canTransferMessage);
var canTransfer1Tx = dct.transfer(account7, "1000000000000", {from: account5, gas: 100000});
var canTransfer2Tx = dct.approve(account8,  "30000000000000000", {from: account6, gas: 100000});
while (txpool.status.pending > 0) {
}
var canTransfer3Tx = dct.transferFrom(account6, account8, "30000000000000000", {from: account8, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("canTransfer1Tx", canTransfer1Tx);
printTxData("canTransfer2Tx", canTransfer2Tx);
printTxData("canTransfer3Tx", canTransfer3Tx);
printBalances();
failIfGasEqualsGasUsed(canTransfer1Tx, canTransferMessage + " - transfer 0.000001 BET ac5 -> ac7. CHECK for movement");
failIfGasEqualsGasUsed(canTransfer2Tx, canTransferMessage + " - approve 0.03 BET ac6 -> ac8");
failIfGasEqualsGasUsed(canTransfer3Tx, canTransferMessage + " - transferFrom 0.03 BET ac6 -> ac8. CHECK for movement");
printDctContractDetails();
console.log("RESULT: ");
}

EOF
# grep "DATA: " $TEST2OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
# cat $DEPLOYMENTDATA
grep "RESULT: " $TEST2OUTPUT | sed "s/RESULT: //" > $TEST2RESULTS
cat $TEST2RESULTS
