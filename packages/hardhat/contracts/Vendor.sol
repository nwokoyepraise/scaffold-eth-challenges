pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    event SellTokens(
        address seller,
        uint256 amountOfTokens,
        uint256 amountOfETH
    );
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    uint256 public constant tokensPerEth = 100;
    YourToken public yourToken;

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
    }

    // ToDo: create a payable buyTokens() function:
    function buyTokens() public payable {
        require(msg.value > 0, "Send ETH to buy some tokens");

        uint256 amountToBuy = msg.value * tokensPerEth;

        // check if the Vendor Contract has enough amount of tokens for the transaction
        uint256 vendorBalance = yourToken.balanceOf(address(this));
        require(
            vendorBalance >= amountToBuy,
            "transfer amount exceeds balance"
        );

        // Transfer token to the msg.sender
        bool sent = yourToken.transfer(msg.sender, amountToBuy);
        require(sent, "Failed to transfer token to user");

        // emit the event
        emit BuyTokens(msg.sender, msg.value, amountToBuy);
    }

    // ToDo: create a withdraw() function that lets the owner withdraw ETH
    function withdraw() public onlyOwner {
        uint256 totalAmount = address(this).balance;
        address owner = msg.sender;
        require(totalAmount > 0, "Not enough Eth available");
        (bool success, ) = owner.call{value: totalAmount}("");
        require(success, "Failed to withdraw Eth");
    }

    // ToDo: create a sellTokens() function:
    function sellTokens(uint256 amount) public {
        uint256 saleAmount = amount / tokensPerEth;
        yourToken.transferFrom(msg.sender, address(this), amount);
        (bool sent, bytes memory data) = msg.sender.call{value: saleAmount}("");
        emit SellTokens(msg.sender, amount, saleAmount);
    }
}

// pragma solidity 0.8.4;
// // SPDfX-License-Identifier: MIT

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "./YourToken.sol";

// contract Vendor is Ownable {
//     YourToken yourToken;

//     uint256 public tokensPerEth = 100;

//     event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
//     event SellTokens(
//         address seller,
//         uint256 amountOfTokens,
//         uint256 amountOfETH
//     );

//     constructor(address tokenAddress) {
//         yourToken = YourToken(tokenAddress);
//     }

//     function buyTokens() public payable returns (uint256 tokenAmount) {
//         require(msg.value > 0, "Send ETH to buy some tokens");
//         uint256 amountToBuy = msg.value * tokensPerEth;
//         uint256 vendorBalance = yourToken.balanceOf(address(this));
//         require(
//             vendorBalance >= amountToBuy,
//             "Vendor contract does not have enough tokens in its balance"
//         );
//         bool sent = yourToken.transfer(msg.sender, amountToBuy);
//         require(sent, "Failed to transfer token to user");
//         emit BuyTokens(msg.sender, msg.value, amountToBuy);
//         return amountToBuy;
//     }

//     function sellTokens(uint256 tokenAmountToSell) public {
//         require(
//             tokenAmountToSell > 0,
//             "Amount should be greater than zero"
//         );
//         uint256 userBalance = yourToken.balanceOf(msg.sender);
//         require(
//             userBalance >= tokenAmountToSell,
//             "Your balance is lower than the amount of tokens you want to sell"
//         );
//         uint256 amountOfETHToTransfer = tokenAmountToSell / tokensPerEth;
//         uint256 ownerETHBalance = address(this).balance;
//         require(
//             ownerETHBalance >= amountOfETHToTransfer,
//             "Vendor has not enough funds to accept the sell request"
//         );

//         bool sent = yourToken.transferFrom(
//             msg.sender,
//             address(this),
//             tokenAmountToSell
//         );
//         require(sent, "Failed to transfer tokens from user to vendor");

//         (sent, ) = msg.sender.call{value: amountOfETHToTransfer}("");
//         require(sent, "Failed to send ETH to the user");
//     }

//     function withdraw() public onlyOwner {
//         uint256 ownerBalance = address(this).balance;
//         require(ownerBalance > 0, "Owner has not balance to withdraw");
//         (bool sent, ) = msg.sender.call{value: address(this).balance}("");
//         require(sent, "Failed to send user balance back to the owner");
//     }
// }
