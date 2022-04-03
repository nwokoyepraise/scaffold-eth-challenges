// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    deadline = block.timestamp + 1 days;
  }

  mapping (address => uint) public balances;

  uint public constant threshold = 1 ether;

  uint public immutable deadline;

  event Stake (
    address staker,
    uint amount
  );

  modifier afterDeadline() {
    require(block.timestamp < deadline, "Deadline has not been reached");
    _;
  }
  
  modifier notCompleted() {
    require(!exampleExternalContract.completed(), "Deadline has been reached");
    _;
  }

  function stake() payable external {
    require (block.timestamp < deadline, "Stake period is over");
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

  function execute() external notCompleted afterDeadline {
    require(address(this).balance >= threshold, "Threshold is not met");

    exampleExternalContract.complete{value: address(this).balance}();
  }

  function withdraw() external notCompleted afterDeadline {
    require(address(this).balance < threshold, "Threshhold met");

    uint amount = balances[msg.sender];
    balances[msg.sender] = 0;
    (bool ok, ) = payable(msg.sender).call{value: amount}("");
    require(ok);
  }

  function timeLeft() public view returns (uint left) {
    if (block.timestamp < deadline) left = deadline - block.timestamp;
  }

}