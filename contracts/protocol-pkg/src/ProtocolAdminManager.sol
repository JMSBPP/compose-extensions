// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;


import {IComponent} from "compose-extensions/GenericFactory/LibGenericFactory.sol";
import {IERC1155Receiver} from "Compose/interfaces/IERC1155Receiver.sol";

interface IProtocolAdminManager{}

contract ProtocolAdminManager is IComponent, IERC1155Receiver, IProtocolAdminManager{

    function initialize(address creator) external{}
    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data)
        external
        returns (bytes4){
            // TODO: It sets the protocoll as created and this uncloks the create_pool to be called
            // by the caller address, additioanlly the caller can now use this contract
            // to custom his protocol
        }

    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external returns (bytes4){}
}

