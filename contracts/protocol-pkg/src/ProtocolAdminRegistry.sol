// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import {LibGenericFactory} from "compose-extensions/GenericFactory/LibGenericFactory.sol";
import "./ProtocolAdminOperator.sol";

interface IProtocolAdminRegistry{
    function initialize() external;
    function deploy_admin_operator(uint256 _tokenId) external returns(address);
}

contract ProtocolAdminRegistry is IProtocolAdminRegistry{
    
    bytes32 constant STORAGE_POSITION = keccak256("hook-bazaar.adminRegistry");

    struct ProtocolAdminRegistryStorage{
        // NOTE: One protocol has one admin
        mapping(uint256 tokenId => address protocol_manager) protocol_manager;
        mapping(uint256 tokenId => address protocol_admin_operators) protocol_admin_operators;
    }


    function getStorage() internal pure returns (ProtocolAdminRegistryStorage storage s) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    function initialize() external{
        LibGenericFactory.initialize(msg.sender);
        LibGenericFactory.setImplementation(address(new ProtocolAdminOperator()));

    }



    function deploy_admin_operator(uint256 _tokenId) external returns(address){
        ProtocolAdminRegistryStorage storage $ = getStorage();

        if ($.protocol_admin_operators[_tokenId] == address(0x00)){
            $.protocol_admin_operators[_tokenId] = LibGenericFactory.createProxy(address(0x00), false, bytes(""));
        }

        return $.protocol_admin_operators[_tokenId];
    }





}