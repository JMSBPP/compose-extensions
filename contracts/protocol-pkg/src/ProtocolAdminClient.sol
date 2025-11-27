// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;


import  "./ProtocolAdminPanel.sol";
import {ProtocolFactoryFacet} from "./ProtocolFactoryFacet.sol"; 

interface IProtocolAdminClient{
    error Uninitialized__AdminClient();
    function __init__() external;
    function create_protocol(string calldata _name) external returns(uint256);
    
}


abstract contract ProtocolAdminClient is IProtocolAdminClient{
    
    bytes32 constant PROTOCOL_ADMIN_CLIENT_POSITION = keccak256("hook-bazaar.protocol.admin-client");    

    struct ProtocolAdminClientStorage{
        address admin_panel;
        uint256 nextTokenId;
    }

    constructor(){
        ProtocolAdminClientStorage storage $ = getStorage();
        $.nextTokenId = uint256(0x01);

    }

    function getStorage() internal pure returns (ProtocolAdminClientStorage storage s) {
        bytes32 position = PROTOCOL_ADMIN_CLIENT_POSITION;
        assembly {
            s.slot := position
        }
    }

    
    function __init__() external{
        // TODO: Strong check for admin panel impl contract
        ProtocolAdminClientStorage storage $ = getStorage();
        $.admin_panel = address(new ProtocolAdminPanel());

    }

    
    function create_protocol(string calldata _name) external returns(uint256){
        ProtocolAdminClientStorage storage $ = getStorage();

        // NOTE: This only checks the address is not Zero, which
        // is equivalent to checking the contract has been initialized
        // because the code on address requirement is checked at __init__
        if ($.admin_panel == address(0x00)) revert Uninitialized__AdminClient();

        // address _protocol_factory = IProtocolAdminPanel($.admin_panel).registry();
        uint256 _token_id = $.nextTokenId;
        address _protocol_admin_operator = IProtocolAdminRegistry($.admin_panel).deploy_admin_operator(_token_id);
        IProtocolFactory($.admin_panel).create_protocol(_protocol_admin_operator, _token_id);
        // NOTE: Here it deploys and assigns a protocolAdmin
        // contract to the caller if it does not have one
        // already, if it has one it a
        
        return _token_id;
    }

    // function factory() external returns(address){
    //     ProtocolAdminClientStorage storage $ = getStorage();
    //     address _factory = $.factory == address(0x00) ?  address(new ProtocolFactoryFacet()): $.factory;
    //     return _factory;
    //     address _protocol  = IGenericFactory(_factory).createProxy(
    //         $.protocol_implementation,
    //         false,
    //         abi.encode("0x00")
    //     );
    // }
}