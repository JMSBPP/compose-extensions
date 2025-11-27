// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Test, console2} from "forge-std/Test.sol";
import "../src/ProtocolAdminPanel.sol";


contract ProtocolAdminPanelTest is Test{


    address protocol_admin_panel;

    address erc1155_facet;
    address erc165_facet;
    
    address protocol_factory_facet;

    address deployer = makeAddr("deployer");

    function setUp() public{
        erc1155_facet = address(new ERC1155Facet());
        erc165_facet = address(new ERC165Facet());

        protocol_factory_facet = address(new ProtocolFactoryFacet());
        // NOTE: This assumes the factory is fully tested
        vm.startPrank(deployer);

        IProtocolFactory(protocol_factory_facet).initialize();

        vm.stopPrank();

        // protocol_admin_panel = 

    }

    function test__unit__regsitrySuccess() public {
        //=============PRE-CONDITIONS==================



        //===============TEST==========================
        

        //============POST-CONDITIONS==================

    }
}