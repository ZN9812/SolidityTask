// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './IERC721Receiver.sol';

contract ERC721 {
    string public name;
    string public symbol;

    // 다음에 발행될 토큰 ID
    uint256 public nextTokenIdToMint; 
    address public contractOwner;

    // token id => owner (소유자 주소 매핑)
    mapping(uint256 => address) internal _owners;

    // owner => token count (소유자 주소 -> 보유 토큰 수)
    mapping(address => uint256) internal _balances;

    // token id => approved address (승인된 주소 (단일 토큰에 대한 권한 위임))
    mapping(uint256 => address) internal _tokenApprovals;
    
    // owner => (operator => yes/no) ( 소유자 -> (오퍼레이터 => 권한 여부) (모든 토큰에 대한 권한 위임))
    mapping(address => mapping(address => bool)) internal _operatorApprovals;

    // token id => token uri (토큰 메타데이터 URI)
    mapping(uint256 => string) _tokenUris;

    // 토큰 전송 발생 시
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    // 단일 토큰 승인 시
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    // 전체 권한 위임 설정/해제 시
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        nextTokenIdToMint = 0;
        contractOwner = msg.sender;
    }

    // 특정 주소가 가진 토큰 수 변환
    function balanceOf(address _owner) public view returns(uint256) {
        require(_owner != address(0), "!Add0");
        return _balances[_owner];
    }

    // 특정 토큰의 소유자 반환
    function ownerOf(uint256 _tokenId) public view returns(address) {
        return _owners[_tokenId];
    }

    // 데이터 없이 호출 가능 (overloading)
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    // to가 contract일 때 수신 확인 조건문
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public payable {
        require(ownerOf(_tokenId) == msg.sender || _tokenApprovals[_tokenId] == msg.sender || _operatorApprovals[ownerOf(_tokenId)][msg.sender], "!Auth");
        _transfer(_from, _to, _tokenId);
        // trigger func check
        require(_checkOnERC721Received(_from, _to, _tokenId, _data), "!ERC721Implementer");
    }

    // onERC721Received 확인 없이 전송 (contract에 보낼 때 위험)
    function transferFrom(address _from, address _to, uint256 _tokenId) public payable {
        // unsafe transfer without onERC721Received, used for contracts that dont implement
        require(ownerOf(_tokenId) == msg.sender || _tokenApprovals[_tokenId] == msg.sender || _operatorApprovals[ownerOf(_tokenId)][msg.sender], "!Auth");
        _transfer(_from, _to, _tokenId);
    }

    // 특정 토큰에 대한 단일 승인 설정
    function approve(address _approved, uint256 _tokenId) public payable {
        require(ownerOf(_tokenId) == msg.sender, "!Owner");
        _tokenApprovals[_tokenId] = _approved;
        emit Approval(ownerOf(_tokenId), _approved, _tokenId);
    }

    // 전체 권한 위임 (모든 토큰에 대해 _operator가 조작 가능)
    function setApprovalForAll(address _operator, bool _approved) public {
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    // 특정 토큰의 승인된 주소 반환
    function getApproved(uint256 _tokenId) public view returns (address) {
        return _tokenApprovals[_tokenId];
    }

    // 전체 권한 위임 여부 반환 
    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return _operatorApprovals[_owner][_operator];
    }

    // 민팅: 오직 컨트랙트 소유자만 가능
    function mintTo(address _to, string memory _uri) public {
        require(contractOwner == msg.sender, "!Auth");
        
        _owners[nextTokenIdToMint] = _to;
        _balances[_to] += 1;
        _tokenUris[nextTokenIdToMint] = _uri;

        emit Transfer(address(0), _to, nextTokenIdToMint);
        nextTokenIdToMint += 1;
    }

    // 특정 토큰의 메타데이터 URI 반환
    function tokenURI(uint256 _tokenId) public view returns(string memory) {
        return _tokenUris[_tokenId];
    }

    // 총 발행된 토큰 수 반환
    function totalSupply() public view returns(uint256) {
        return nextTokenIdToMint;
    }

    // 내부 함수: safeTransfer일 때 수신자가 컨ㅌ랙트면, 수신 함수 존재 여부 확인
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        // check if to is an contract, if yes, to.code.length will always > 0
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    // unsafe transfer
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _from, "!Owner"); // 소유자 확인
        require(_to != address(0), "!ToAdd0"); // 0번 주소 전송 금지

        delete _tokenApprovals[_tokenId]; // 기존 승인 내역 제거
        _balances[_from] -= 1;
        _balances[_to] += 1;
        _owners[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }
}