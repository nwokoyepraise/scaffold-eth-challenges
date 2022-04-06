// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract ExampleExternalContract {
    bool public completed;

    // constructor(address exampleExternalContractAddress) {
    //     exampleExternalContract = ExampleExternalContract(
    //         exampleExternalContractAddress
    //     );
    // }

    function complete() public payable {
        completed = true;
    }
}
