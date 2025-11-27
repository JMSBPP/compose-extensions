// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;



import {IERC165} from "forge-std/interfaces/IERC165.sol";
import {LibERC165} from "Compose/interfaceDetection/ERC165/LibERC165.sol";
import {ERC165Facet} from "Compose/interfaceDetection/ERC165/ERC165Facet.sol";


import {IERC1155} from "Compose/interfaces/IERC1155.sol";
import {LibERC1155} from "Compose/token/ERC1155/LibERC1155.sol";
import {ERC1155Facet} from "Compose/token/ERC1155/ERC1155Facet.sol";

// import {GenericFactory} from "euler-vault-kit/src/GenericFactory/GenericFactory.sol";

// interface IGenericFactory{
//     function createProxy(address desiredImplementation, bool upgradeable, bytes memory trailingData) external returns (address);
// }




interface IProtocolFactory{
    function initialize() external;
    function create_protocol(address _protocol_admin, uint256 _token_id) external;
}


// @notice Storage slot identifier for ERC-165 interface detection
// @dev Defined using keccak256 hash following ERC-8042 standard
// keccak256(hooks-bazaar.protocol-factory)

// uint256 constant PROTOCOL_FACTORY_STORAGE_POSITION = 2220184280574732288333510600956514732965581379269956828305363449220455080129; 

// contract ProtocolFactory is IProtocolFactory, GenericFactory layout at 2220184280574732288333510600956514732965581379269956828305363449220455080129{
//     constructor() GenericFactory(msg.sender){}
// } 

contract ProtocolFactoryFacet is IProtocolFactory{
    bytes32 constant STORAGE_POSITION = keccak256("hook-bazaar.protocol-factory");

    struct ProtocolFactoryStorage{
        uint256 data;
    }

    function getStorage() internal pure returns (ProtocolFactoryStorage storage $) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            $.slot := position
        }
    }

    function initialize() external{
        ProtocolFactoryStorage storage $ = getStorage();
        // TODO: Check the facet implementations are valid
    }

    function create_protocol(address _protocol_admin, uint256 _token_id) external{

        // TODO: This library must also expose a payload to the protocol admin
        // and perform checks against the protocol_admin
        LibERC1155.mint(_protocol_admin,_token_id,uint256(0x01));       
    }






}