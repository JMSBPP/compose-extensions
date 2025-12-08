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
    
    bytes32 constant STORAGE_POSITION = keccak256("compose-extension.generic-factory");
    

    struct ProxyConfig {
        // If true, proxy is an instance of the BeaconProxy
        bool upgradeable;
        // Address of the implementation contract
        // May be an out-of-date value, if upgradeable (handled by getProxyConfig)
        address implementation;
        // The metadata attached to every call passing through the proxy
        bytes trailingData;
    }

    struct GenericFactoryStorage{
        address upgradeAdmin;
        address implementation;
        mapping(address proxy => ProxyConfig) proxyLookup;
        address[] proxyList;
    }
    
    function getStorage() internal pure returns (GenericFactoryStorage storage s) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
    
    function upgradeAdmin() internal returns(address){
       GenericFactoryStorage storage $ = getStorage();
        return $.upgradeAdmin;
    }
    function implementation() internal returns(address){
        GenericFactoryStorage storage $ = getStorage();
        return $.implementation;
    }

    function proxyLookup(address proxy) internal returns(ProxyConfig memory){
        GenericFactoryStorage storage $ = getStorage();
        return $.proxyLookup[proxy];
    }

    function proxyList() internal returns(address[] memory){
        GenericFactoryStorage storage $ = getStorage();
        return $.proxyList; 
    }


    event Genesis();

    event ProxyCreated(address indexed proxy, bool upgradeable, address implementation, bytes trailingData);

    event SetImplementation(address indexed newImplementation);

    event SetUpgradeAdmin(address indexed newUpgradeAdmin);


    error E_Reentrancy();
    error E_Unauthorized();
    error E_Implementation();
    error E_BadAddress();
    error E_BadQuery();

    
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
        internal 
        nonReentrant
        returns (address)
        {
            GenericFactoryStorage storage $ = getStorage();
        
            address _implementation = $.implementation;
            if (desiredImplementation == address(0)) desiredImplementation = _implementation;
        

            if (desiredImplementation == address(0) || desiredImplementation != _implementation) revert E_Implementation();
        
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
                ProxyConfig({upgradeable: upgradeable, implementation: desiredImplementation, trailingData: trailingData});
    
            $.proxyList.push(proxy);
        
        
            IComponent(proxy).initialize(msg.sender);
        
            emit ProxyCreated(proxy, upgradeable, desiredImplementation, trailingData);
        
            return proxy;
        }

    function setImplementation(address newImplementation) internal nonReentrant adminOnly {
        GenericFactoryStorage storage $ = getStorage();
        if (newImplementation.code.length == 0) revert E_BadAddress();
            $.implementation = newImplementation;
            emit SetImplementation(newImplementation);
    }

    function setUpgradeAdmin(address newUpgradeAdmin) internal nonReentrant adminOnly {
        GenericFactoryStorage storage $ = getStorage();
        $.upgradeAdmin = newUpgradeAdmin;
        emit SetUpgradeAdmin(newUpgradeAdmin);
    }

}