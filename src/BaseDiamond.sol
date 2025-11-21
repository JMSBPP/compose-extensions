// SPDX-License-Identifier: MIT
pragma solidity >=0.8.29;

import {DiamondCutFacet} from "Compose/src/diamond/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "Compose/src/diamond/DiamondLoupeFacet.sol";
// import {LibDiamond} from "Compose/src/diamond/LibDiamond.sol";

interface IDiamond{
    function cut() external view returns(address);
    function loupe() external view returns(address);
    
}

interface IDiamondCutFacet{
    
    function diamondCut(DiamondCutFacet.FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external;
}


interface IDiamondLoupeFacet{
    struct Facet {
        address facet;
        bytes4[] functionSelectors;
    }

    function facetAddress(bytes4 _functionSelector) external view returns (address facet);
    function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetSelectors);
    function facets() external view returns (Facet[] memory facetsAndSelectors);
    function facetAddresses() external view returns (address[] memory allFacets);

}

library LibBaseDiamond{
    bytes32 constant BASE_DIAMOND_STORAGE_POSITION = keccak256("compose-extension.diamond.base");    

    struct BaseDiamondStorage{
        address cut;
        address loupe;
    }

    function getBaseStorage() internal pure returns (BaseDiamondStorage storage s) {
        bytes32 position = BASE_DIAMOND_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    function __init__(address _authorized_caller ) internal{
                DiamondCutFacet.FacetCut[] memory _diamond_facets_functions = new DiamondCutFacet.FacetCut[](uint256(0x01));
        BaseDiamondStorage storage $ = getBaseStorage();



        {
            address _diamond_cut_facet = address(new DiamondCutFacet());

            assembly("memory-safe"){
                sstore(0x0a3f54f528e7e1203573e58b7506067ecaaadb5458729147354c2910780e9eaa,_authorized_caller)
            }
            
  

            _diamond_facets_functions[0x00] = DiamondCutFacet.FacetCut(
                _diamond_cut_facet,
                DiamondCutFacet.FacetCutAction.Add,
                new bytes4[](uint256(0x01))
            );

            _diamond_facets_functions[0x00].functionSelectors[0x00] = IDiamondCutFacet.diamondCut.selector;
            (bool _ok, bytes memory _res) = _diamond_cut_facet.delegatecall(
                abi.encodeCall(
                    IDiamondCutFacet.diamondCut,
                    (
                        _diamond_facets_functions,
                        address(0x00),
                        abi.encode("0x00")
                    )
                )
            );
            

            $.cut = _diamond_cut_facet;
        }

        // NOTE: Setting the diamond loupe facet
        {
            address _diamond_loupe_facet = address(new DiamondLoupeFacet());
            _diamond_facets_functions[0x00] = DiamondCutFacet.FacetCut(
                _diamond_loupe_facet,
                DiamondCutFacet.FacetCutAction.Add,
                new bytes4[](uint256(0x04))
            );
            _diamond_facets_functions[0x00].functionSelectors[0x00] = IDiamondLoupeFacet.facetAddresses.selector;
            _diamond_facets_functions[0x00].functionSelectors[0x01] = IDiamondLoupeFacet.facetFunctionSelectors.selector;
            _diamond_facets_functions[0x00].functionSelectors[0x02] = IDiamondLoupeFacet.facets.selector;
            _diamond_facets_functions[0x00].functionSelectors[0x03] = IDiamondLoupeFacet.facetAddress.selector;
            (bool _ok, bytes memory _res) = $.cut.delegatecall(
                abi.encodeCall(
                    IDiamondCutFacet.diamondCut,
                    (
                        _diamond_facets_functions,
                        address(0x00),
                        abi.encode("0x00")
                    )
                )
            );

            $.loupe = _diamond_loupe_facet;
        }
    }



}

abstract contract BaseDiamond is IDiamond{
    bytes32 constant BASE_DIAMOND_STORAGE_POSITION = keccak256("compose-extension.diamond.base");

    struct BaseDiamondStorage{
        address cut;
        address loupe;
    }

    function getBaseStorage() internal pure returns (BaseDiamondStorage storage s) {
        bytes32 position = BASE_DIAMOND_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    function cut() public view returns(address){
        BaseDiamondStorage storage $ = getBaseStorage();
        return $.cut;
    }


    function loupe() public view returns(address){
        BaseDiamondStorage storage $ = getBaseStorage();
        return $.loupe;
    }
    

    function __init__(address _authorized_caller ) external{
        
        // NOTE: Setting the diamond cut facet
        DiamondCutFacet.FacetCut[] memory _diamond_facets_functions = new DiamondCutFacet.FacetCut[](uint256(0x01));
        BaseDiamondStorage storage $ = getBaseStorage();



        {
            address _diamond_cut_facet = address(new DiamondCutFacet());

            assembly("memory-safe"){
                sstore(0x0a3f54f528e7e1203573e58b7506067ecaaadb5458729147354c2910780e9eaa,_authorized_caller)
            }
            
  

            _diamond_facets_functions[0x00] = DiamondCutFacet.FacetCut(
                _diamond_cut_facet,
                DiamondCutFacet.FacetCutAction.Add,
                new bytes4[](uint256(0x01))
            );

            _diamond_facets_functions[0x00].functionSelectors[0x00] = IDiamondCutFacet.diamondCut.selector;
            (bool _ok, bytes memory _res) = _diamond_cut_facet.delegatecall(
                abi.encodeCall(
                    IDiamondCutFacet.diamondCut,
                    (
                        _diamond_facets_functions,
                        address(0x00),
                        abi.encode("0x00")
                    )
                )
            );
            

            $.cut = _diamond_cut_facet;
        }

        // NOTE: Setting the diamond loupe facet
        {
            address _diamond_loupe_facet = address(new DiamondLoupeFacet());
            _diamond_facets_functions[0x00] = DiamondCutFacet.FacetCut(
                _diamond_loupe_facet,
                DiamondCutFacet.FacetCutAction.Add,
                new bytes4[](uint256(0x04))
            );
            _diamond_facets_functions[0x00].functionSelectors[0x00] = IDiamondLoupeFacet.facetAddresses.selector;
            _diamond_facets_functions[0x00].functionSelectors[0x01] = IDiamondLoupeFacet.facetFunctionSelectors.selector;
            _diamond_facets_functions[0x00].functionSelectors[0x02] = IDiamondLoupeFacet.facets.selector;
            _diamond_facets_functions[0x00].functionSelectors[0x03] = IDiamondLoupeFacet.facetAddress.selector;
            (bool _ok, bytes memory _res) = $.cut.delegatecall(
                abi.encodeCall(
                    IDiamondCutFacet.diamondCut,
                    (
                        _diamond_facets_functions,
                        address(0x00),
                        abi.encode("0x00")
                    )
                )
            );

            $.loupe = _diamond_loupe_facet;
        }
    }



}
