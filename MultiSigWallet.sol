// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract MultisigWallet {

    address public owner;

    struct Proposal {
        uint256 id;
        address to;
        uint256 value;
        bytes data;
        uint256 yesVotes;
        uint256 noVotes;
        uint256 createdAt;
        bool executed;
    }

    Proposal[] public proposals;

    mapping(address => bool) public isVoter;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    modifier onlyOwner() {
        require(msg.sender == owner, "!Owner");
        _;
    }

    constructor(address[] memory _voters) {
        owner = msg.sender;
        for (uint256 i = 0; i < _voters.length; i++) {
            isVoter[_voters[i]] = true;
        }
    }

    // 새로운 트랜잭션 안건 추가 (배포자만 가능)
    function addProposal(address _to, uint256 _value, bytes memory _data) public onlyOwner {
        proposals.push(Proposal({
            id: proposals.length,
            to: _to,
            value: _value,
            data: _data,
            yesVotes: 0,
            noVotes: 0,
            createdAt: block.timestamp,
            executed: false
        }));
    }

    // ECDSA 서명 기반 투표 (찬성 또는 반대)
    function vote(uint256 _id, bool _support, bytes memory _signature) public {
        require(_id < proposals.length, "Invalid ID");
        Proposal storage proposal = proposals[_id];
        require(!hasVoted[_id][recoverSigner(_id, proposal.to, proposal.value, proposal.data, _signature)], "Already voted");

        address signer = recoverSigner(_id, proposal.to, proposal.value, proposal.data, _signature);
        require(isVoter[signer], "!Voter");

        if (_support) {
            proposal.yesVotes += 1;
        } else {
            proposal.noVotes += 1;
        }
        hasVoted[_id][signer] = true;
    }

    // 서명 기반 실행 (안건 통과 시 실행)
    function executeProposal(uint256 _id) public {
        require(_id < proposals.length, "Invalid ID");
        Proposal storage proposal = proposals[_id];
        require(!proposal.executed, "Already executed");
        require(proposal.yesVotes > proposal.noVotes, "Not approved");

        proposal.executed = true;

        (bool success, ) = proposal.to.call{value: proposal.value}(proposal.data);
        require(success, "Tx failed");
    }

    // 메시지 해시 생성
    function getMessageHash(uint256 _id, address _to, uint256 _value, bytes memory _data) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_id, _to, _value, _data));
    }

    // 서명 검증을 위한 signer 복원
    function recoverSigner(uint256 _id, address _to, uint256 _value, bytes memory _data, bytes memory _signature) public pure returns (address) {
        bytes32 messageHash = getMessageHash(_id, _to, _value, _data);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recover(ethSignedMessageHash, _signature);
    }

    // Ethereum 메시지 포맷 적용
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    // ECDSA 복원 (ecrecover)
    function recover(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address) {
        require(_signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    // 컨트랙트 잔액 확인
    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // 수신 가능
    receive() external payable {}
}