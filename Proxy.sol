// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Proxy {
    address public implementation;
    address public admin;

    constructor(address _implementation) {
        implementation = _implementation;
        admin = msg.sender;
    }

    function upgrade(address _newImplementation) external {
        require(msg.sender == admin, "Only admin");
        implementation = _newImplementation;
    }

    fallback() external payable {
        address impl = implementation;
        require(impl != address(0), "No implementation");

        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}
