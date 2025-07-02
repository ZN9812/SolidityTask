// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ERC20.sol";

contract ERC20V2_Blacklist is ERC20 {
    
    address constant BLACKLISTED = 0x3133700000000000000000000000000000000000;

    function transfer(address _to, uint256 _value) public override returns (bool) {
        require(_to != BLACKLISTED, "Blacklisted address");
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        require(_to != BLACKLISTED, "Blacklisted address");
        return super.transferFrom(_from, _to, _value);
    }
}
