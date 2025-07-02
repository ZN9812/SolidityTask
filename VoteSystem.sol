// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract VotingSystem {
    address public owner;

    struct Proposal {
        uint256 id;
        string desciption;
        uint256 yesVotes;
        uint256 noVotes;
        uint256 createAt;
        bool resultChecked;
    }

    Proposal[] public proposals;

    mapping(address => bool) public isVoter;
    mapping(uint256 => mapping(address => bool)) public hasVoted; // proposalId -> (voter => voted)

    modifier onlyOwner() {
        require(msg.sender == owner, "!Owner");
        _;
    }

    modifier onlyVoter() {
        require(isVoter[msg.sender], "!Voter");
        _;
    }

    constructor(address[] memory _voters) {
        owner = msg.sender;

        // 지정된 주소들에게 voter 권한 부여
        for (uint256 i = 0; i < _voters.length; i++) {
            isVoter[_voters[i]] = true;
        }
    }

    // 배포자만 새로운 안건 추가
    function addProposal(string memory _description) public onlyOwner {
        proposals.push(Proposal({
            id: proposals.length,
            description: _description,
            yesVoter: 0,
            noVoter: 0,
            createdAt: block.timestamp,
            resultChekced: false
        }));
    }

    // voter만 특정 안건 확인
    function viewProposal(uint256 _id) public view onlyVoter returns (Proposal memory) {
        require(_id < proposals.length, "Invalid ID");
        return proposals[_id];
    }

    // voter만 투표 가능 (중복 투표 방지)
    function vote(uint256 _id, bool _support) public onlyVoter {
        require(_id < proposals.length, "Invalid ID");
        require(!hasVoted[_id][msg.sender], "Already voted");

        Proposal storage proposal = proposals[_id];

        if (_support) {
            proposal.yesVotes += 1;
        } else {
            proposal.noVotes += 1;
        }

        hasVoted[_id][msg.sender] = true;
    }

    // 안건 생성 후 5분 이후 결과 판단
    function checkResult(uint256 _id) public view returns (string memory) {
        require(_id < proposals.length, "Invalid ID");
        Proposal memory proposal = proposals[_id];
        require(block.timestamp >= proposal.createAt + 5 minutes, "Too early");

        if (proposal.yesVotes > proposal.noVotes) {
            return "Proposal Passed";
        } else if (proposal.noVotes > proposal.yesVotes) {
            return "Proposal Rejected";
        } else {
            return "Tie";
        }
    }
}