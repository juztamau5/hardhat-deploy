// SPDX-License-Identifier: MIT
pragma solidity ^0.7.1;
pragma experimental ABIEncoderV2;

import "./interfaces/IDiamondCut.sol";
import "./Diamond.sol";

contract Diamantaire {
    event DiamondCreated(Diamond diamond);

    function createDiamond(
        address owner,
        IDiamondCut.FacetCut[] calldata _diamondCut,
        bytes calldata data,
        bytes32 salt
    ) external payable returns (Diamond diamond) {
        Diamond.DiamondArgs memory args;
        args.owner = address(this);

        if (salt != 0x0000000000000000000000000000000000000000000000000000000000000000) {
            salt = keccak256(abi.encodePacked(salt, owner));
            diamond = new Diamond{value: msg.value, salt: salt}(_diamondCut, args);
        } else {
            diamond = new Diamond{value: msg.value}(_diamondCut, args);
        }
        emit DiamondCreated(diamond);

        IDiamondCut(address(diamond)).diamondCut(_diamondCut, data.length > 0 ? address(diamond) : address(0), data);
        IERC173(address(diamond)).transferOwnership(owner);
    }
}
