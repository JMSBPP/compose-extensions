// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Test, console2} from "forge-std/Test.sol";
import "../src/ProtocolFactoryFacet.sol";


contract ProtocolFactoryFacetTest is Test{


    address erc1155_facet;
    address erc165_facet;
    address protocol_factory_facet;
    
    function setUp() public{
        erc1155_facet = address(new ERC1155Facet());
        erc165_facet = address(new ERC165Facet());

        protocol_factory_facet = address(new ProtocolFactoryFacet());

    }

    function test__unit__initSuccess() public{
        //==========PRE-CONDITIONS==================
    
        //=============TEST=======================


        //============POST-CONDITIONS=============

    }

    function test__unit__initFailed() public {
        //============PRE-CONDITIONS=============


        //===============TEST====================


        //=========POST-CONDITIONS===============
    }

    function test__unit__createProtocolSucess() public {

        //=========PRE-CONDITIONS===============



        //=============TEST===================


        //============POST-CONDITIONS ===============
    }
}