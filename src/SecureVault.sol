// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SecureVault {
    address public owner;
    address public arbiter;

    // Whitelist of addresses authorized for withdrawals
    mapping(address => bool) public allowedWithdrawalAddresses;
    mapping(address => bool) public isAuthorized;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Whitelist Management (Owner Only)
    function setAllowedAddress(address _addr, bool _status) external onlyOwner {
        allowedWithdrawalAddresses[_addr] = _status;
    }

    function registerArbiter(address _newArbiter) external onlyOwner {
        arbiter = _newArbiter;
        isAuthorized[_newArbiter] = true;
    }

    // The withdrawal function now requires verification of the recipient's address.
    function withdraw(address to, uint256 amount) external {
        require(isAuthorized[msg.sender], "Not an arbiter");
        require(allowedWithdrawalAddresses[to], "Address not allowed");

        payable(to).transfer(amount);
    }

    receive() external payable {}
}
