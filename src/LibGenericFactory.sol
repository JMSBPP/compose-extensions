// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import "./GenericFactoryMod.sol" as GenericFactoryMod;
import "Compose/libraries/NonReentrancyMod.sol" as NonReentrancyMod;
import {BeaconProxy} from "./BeaconProxy.sol";
import "./MetaProxyDeployerMod.sol" as MetaProxyDeployerMod;

/// @title IComponent
/// @notice Minimal interface which must be implemented by the contract deployed by the factory
interface IComponent {
    /// @notice Function replacing the constructor in proxied contracts
    /// @param creator The new contract's creator address
    function initialize(address creator) external;
}

library LibGenericFactory{
    event ProxyCreated(address indexed proxy, bool upgradeable, address implementation, bytes trailingData);
    modifier nonReentrant() {
        NonReentrancyMod.enter();
        _;
        NonReentrancyMod.exit();
    }

    modifier adminOnly() {
        _adminOnly();
        _;
    }

    function _adminOnly() internal{
        GenericFactoryMod.GenericFactoryStorage storage $ = GenericFactoryMod.getStorage();
        if (msg.sender != $.upgradeAdmin) revert GenericFactoryMod.E_Unauthorized();
        
    }  


    function createProxy(address desiredImplementation, bool upgradeable, bytes memory trailingData)
        external
        nonReentrant
        returns (address)
        {
            GenericFactoryMod.GenericFactoryStorage storage $ = GenericFactoryMod.getStorage();
        
            address _implementation = $.implementation;
            if (desiredImplementation == address(0)) desiredImplementation = _implementation;
        

            if (desiredImplementation == address(0) || desiredImplementation != _implementation) revert GenericFactoryMod.E_Implementation();
        
            // The provided trailing data is prefixed with 4 zero bytes to avoid potential selector clashing in case the
            // proxy is called with empty calldata.
            bytes memory prefixTrailingData = abi.encodePacked(bytes4(0), trailingData);
            address proxy;
        
            if (upgradeable) {
                proxy = address(new BeaconProxy(prefixTrailingData));
            } else {
                proxy = MetaProxyDeployerMod.deployMetaProxy(desiredImplementation, prefixTrailingData);
            }

            $.proxyLookup[proxy] =
                GenericFactoryMod.ProxyConfig({upgradeable: upgradeable, implementation: desiredImplementation, trailingData: trailingData});
    
            $.proxyList.push(proxy);
        
        
            IComponent(proxy).initialize(msg.sender);
        
            emit ProxyCreated(proxy, upgradeable, desiredImplementation, trailingData);
        
            return proxy;
        }

    function setImplementation(address newImplementation) internal nonReentrant adminOnly {
        GenericFactoryMod.GenericFactoryStorage storage $ = GenericFactoryMod.getStorage();
        if (newImplementation.code.length == 0) revert GenericFactoryMod.E_BadAddress();
            $.implementation = newImplementation;
            emit GenericFactoryMod.SetImplementation(newImplementation);
    }

    function setUpgradeAdmin(address newUpgradeAdmin) internal nonReentrant adminOnly {
        GenericFactoryMod.GenericFactoryStorage storage $ = GenericFactoryMod.getStorage();
        $.upgradeAdmin = newUpgradeAdmin;
        emit GenericFactoryMod.SetUpgradeAdmin(newUpgradeAdmin);
    }

}