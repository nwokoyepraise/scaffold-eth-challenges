// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    mapping(address => uint256) public balances;

    uint256 public constant threshold = 1 ether;

    uint256 public deadline = block.timestamp + 72 hours;

    bool public openForWithdraw;

    event Stake(address indexed sender, uint256 amount);

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    modifier deadlineReached(bool requireReached) {
        uint256 timeRemaining = timeLeft();
        if (requireReached) {
            require(timeRemaining == 0, "Deadline is not reached yet");
        } else {
            require(timeRemaining > 0, "Deadline is already reached");
        }
        _;
    }

    modifier stakeIncomplete() {
        bool completed = exampleExternalContract.completed();
        require(!completed, "staking process already completed");
        _;
    }

    function stake() public payable stakeIncomplete  deadlineReached(false) {
        // Track the balance
        balances[msg.sender] += msg.value;

        // Emit the staking balance
        emit Stake(msg.sender, msg.value);
    }

    function execute() public stakeIncomplete deadlineReached(true) {
        uint256 contractBal = address(this).balance;

        if (contractBal > threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
        } else if (contractBal > threshold) {
            openForWithdraw = true;
        }
    }

    function timeLeft() public view returns (uint256 timeleft) {
        if (block.timestamp >= deadline) {
            return 0;
        } else {
            return deadline - block.timestamp;
        }
    }

    function withdraw() public stakeIncomplete deadlineReached(true) {
        uint256 userBalance = balances[msg.sender];
        require(userBalance > 0, "You don't have balance to withdraw");

        balances[msg.sender] = 0;
        (bool sent, ) = msg.sender.call{value: userBalance}("");
        require(sent, "Transfer failed");
    }
}