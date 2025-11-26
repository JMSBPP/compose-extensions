// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

// import {DiamondCutFacet} from "Compose/src/diamond/DiamondCutFacet.sol";
// import {DiamondLoupeFacet} from "Compose/src/diamond/DiamondLoupeFacet.sol";
import {LibDiamond} from "Compose/diamond/LibDiamond.sol";
import {Address} from "./libraries/Address.sol";

// TODO: Why not top allow for memroy params on diamondCut, if not appropiate use helper for 
// diamondCutMemory


interface IDiamond{
    error DiamondFunctionNotFound(bytes4 _selector);
    function call_diamondCut(LibDiamond.FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external;
    function diamondCut(LibDiamond.FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external;
}


abstract contract BaseDiamond is IDiamond{

    function call_diamondCut(LibDiamond.FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external{
        Address.functionCall(address(this), abi.encodeCall(IDiamond.diamondCut, (_diamondCut, _init, _calldata)));
    }
    
    function diamondCut(LibDiamond.FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external{
        LibDiamond.diamondCut(_diamondCut,_init, _calldata);
    }    

    fallback() external payable {
        LibDiamond.DiamondStorage storage s = LibDiamond.getStorage();
        address facet = s.facetAndPosition[msg.sig].facet;
        if (facet == address(0)) revert DiamondFunctionNotFound(msg.sig);

        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(0, 0, size)
            switch result
            case 0 { revert(0, size) }
            default { return(0, size) }
        }
    }

    receive() external payable {}



}
