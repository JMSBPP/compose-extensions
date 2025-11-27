// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "compose-extensions/BaseDiamond.sol";

import {IERC1155} from "Compose/interfaces/IERC1155.sol";
import {ERC1155Facet} from "Compose/token/ERC1155/ERC1155Facet.sol";
import "./ProtocolFactoryFacet.sol";
import "./ProtocolAdminRegistry.sol";
import "compose-extensions/GenericFactory/GenericFactoryFacet.sol";

// // NOTE: This contract is the interaction point for protocol
// // developers, AI agents 
interface IProtocolAdminPanel{
    error InvalidDeployer(address);
    error ProtocolAdminPanelInvalidProtocolFactoryInstance(address);
    error ProtocolAdminPanelInvalidProtocolAdminRegistry(address);
    function initialize(address _protocol_admin_registry, address _protocol_factory) external;

}

// TODO: To be considered : IERC5169
// TODO: To be considered: IERC1155Receiver

contract ProtocolAdminPanel is IProtocolAdminPanel, BaseDiamond{
    
    struct ProtocolAdminPanelStorage{
        uint256 data;
    }

    bytes32 constant PROTOCOL_ADMIN_PANEL_STORAGE = keccak256("hook-bazaar.protocol.admin-panel");    



    function getStorage() internal pure returns (ProtocolAdminPanelStorage storage s) {
        bytes32 position = PROTOCOL_ADMIN_PANEL_STORAGE;
        assembly {
            s.slot := position
        }
    }

    function initialize(address _protocol_admin_registry, address _protocol_factory) external{
        ProtocolAdminPanelStorage storage $ = getStorage();
        // TODO: Introspection checks ...
        try IProtocolFactory(_protocol_factory).initialize() {
            {
                bytes4[] memory  _interface = new bytes4[](uint256(0x08));
                
                _interface[0x00] = IERC1155.balanceOf.selector;
                _interface[0x01] = IERC1155.balanceOfBatch.selector;
                _interface[0x02] = IERC1155.setApprovalForAll.selector;
                _interface[0x03] = IERC1155.isApprovedForAll.selector;
                _interface[0x04] = IERC1155.safeTransferFrom.selector;
                _interface[0x05] = IERC1155.safeBatchTransferFrom.selector;
                _interface[0x06] = IERC1155.uri.selector;
                _interface[0x07] = IProtocolFactory.create_protocol.selector;

                LibDiamond.FacetCut[] memory _cut = new LibDiamond.FacetCut[](uint256(0x01));
                _cut[0x00] = LibDiamond.FacetCut(_protocol_factory, LibDiamond.FacetCutAction.Add, _interface);
                IDiamond(address(this)).call_diamondCut(_cut,_protocol_factory,bytes(""));

            }


        } catch (bytes memory _reason){
            if (_reason.length == uint256(0x00)){
                revert ProtocolAdminPanelInvalidProtocolFactoryInstance(_protocol_factory);
            }
        }

        try IProtocolAdminRegistry(_protocol_admin_registry).initialize(){
            {   
                bytes4[] memory  _interface = new bytes4[](uint256(0x07));

                _interface[0x00] = IGenericFactory.setImplementation.selector;
                _interface[0x01] = IGenericFactory.setUpgradeAdmin.selector;
                _interface[0x02] = IGenericFactory.getProxyConfig.selector;
                _interface[0x03] = IGenericFactory.isProxy.selector;
                _interface[0x04] = IGenericFactory.getProxyListLength.selector;
                _interface[0x05] = IGenericFactory.getProxyListSlice.selector;
                _interface[0x06] = IProtocolAdminRegistry.deploy_admin_operator.selector;

                LibDiamond.FacetCut[] memory _cut = new LibDiamond.FacetCut[](uint256(0x01));
                _cut[0x00] = LibDiamond.FacetCut(_protocol_factory, LibDiamond.FacetCutAction.Add, _interface);
                IDiamond(address(this)).call_diamondCut(_cut,_protocol_factory,bytes(""));

            }

        } catch (bytes memory _reason){
            if (_reason.length == uint256(0x00)){
                revert ProtocolAdminPanelInvalidProtocolAdminRegistry(_protocol_admin_registry);
            }
        }

    }



}
