// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {fundStorage} from "./fundStorage.sol";

interface IfundFactory {
    function mediaAddress() external returns (address);

    function logic() external returns (address);

    // ERC20 data.
    function parameters()
        external
        returns (
            address payable builder,
            address payable fundingRecipient,
            uint256 fundingCap,
            uint256 builderPercent,
            string memory name,
            string memory symbol
        );
}

contract fundProxy is fundStorage {
    constructor() {
        logic = IfundFactory(msg.sender).logic();
        // fund-specific data.
        (
            builder,
            fundingRecipient,
            fundingCap,
            builderPercent,
            name,
            symbol
        ) = IfundFactory(msg.sender).parameters();
        // Initialize mutable storage.
        status = Status.FUNDING;
    }

    fallback() external payable {
        address _impl = logic;
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
                case 0 {
                    revert(ptr, size)
                }
                default {
                    return(ptr, size)
                }
        }
    }

    receive() external payable {}
}
