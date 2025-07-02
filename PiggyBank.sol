// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract PersonalPiggyBank {
    // 각 주소별 입금 총액 추적
    mapping(address => uint256) private deposits;

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function myBalance() public view returns (uint256) {
        return deposits[msg.sender];
    }

    // 특정 주소의 잔액 확인 (다른 사람도 조회 가능) 
    function balanceOf(address _user) public view returns (uint256) {
        return deposits[_user];
    }

    // Native Token 입금 (msg.value만큼 입금)
    function deposit() public payable {
        require(msg.value > 0, "Amount must be > 0");
        deposits[msg.sender] += msg.value;
    }

    // 본인 잔액에서 출금
    function withdraw(uint256 _amount) public {
        require(deposits[msg.sender] >= _amount, "Insufficient balance");

        deposits[msg.sender] -= _amount;

        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");
    }

    // 전체 contract 잔액을 받을 수 있을 수 있도록 payable fallback 설정
    receive() external payable {
        deposits[msg.sender] += msg.value;
    }
}