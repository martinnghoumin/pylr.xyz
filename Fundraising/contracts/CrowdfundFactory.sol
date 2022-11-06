// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {fundProxy} from "./fundProxy.sol";

contract fundFactory {
    //======== Structs ========

    struct Parameters {
        address payable builder;
        address payable fundingRecipient;
        uint256 fundingCap;
        uint256 builderPercent;
        string name;
        string symbol;
    }

    //======== Events ========

    event Deployed(
        address fundProxy,
        string name,
        string symbol,
        address builder
    );

    //======== Immutable storage =========

    address public immutable logic;

    //======== Mutable storage =========

    // Gets set within the block, and then deleted.
    Parameters public parameters;

    //======== Constructor =========

    constructor(address logic_) {
        logic = logic_;
    }

    //======== Deploy function =========

    function createfund(
        string calldata name_,
        string calldata symbol_,
        address payable builder_,
        address payable fundingRecipient_,
        uint256 fundingCap_,
        uint256 builderPercent_
    ) external returns (address fundProxy) {
        parameters = Parameters({
            name: name_,
            symbol: symbol_,
            builder: builder_,
            fundingRecipient: fundingRecipient_,
            fundingCap: fundingCap_,
            builderPercent: builderPercent_
        });

        fundProxy = address(
            new fundProxy{
                salt: keccak256(abi.encode(name_, symbol_, builder_))
            }()
        );

        delete parameters;

        emit fundDeployed(fundProxy, name_, symbol_, builder_);
    }
}
