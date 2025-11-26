// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.30;

import {LibNonReentrancy} from "Compose/libraries/LibNonReentrancy.sol";
import {LibAccessControl} from "Compose/access/AccessControl/LibAccessControl.sol";
import {LibMetaProxyDeployer} from "./LibMetaProxyDeployer.sol";
import {BeaconProxy} from "./BeaconProxy.sol";
import {LibInitializable} from "../libraries/LibInitializable.sol";

/// @title IComponent
/// @notice Minimal interface which must be implemented by the contract deployed by the factory

interface IComponent {
    /// @notice Function replacing the constructor in proxied contracts
    /// @param creator The new contract's creator address
    function initialize(address creator) external;
}


library LibGenericFactory{
    error GenericFactoryImplementation();
    error GenericFactoryBadAddress();

    event GenericFactoryGenesis();
    
    event GenericFactoryProxyCreated(address indexed proxy, bool upgradeable, address implementation, bytes trailingData);

    event GenericFactorySetUpgradeAdmin(address indexed newUpgradeAdmin);

    event GenericFactorySetImplementation(address indexed newImplementation);

    struct ProxyConfig {
        // If true, proxy is an instance of the BeaconProxy
        bool upgradeable;
        // Address of the implementation contract
        // May be an out-of-date value, if upgradeable (handled by getProxyConfig)
        address implementation;
        // The metadata attached to every call passing through the proxy
        bytes trailingData;
    }

    bytes32 constant STORAGE_POSITION = keccak256("compose.genericfactory");
    bytes32 constant UPGRADE_ADMIN_ROLE = keccak256("upgrade_admin_role");


    struct GenericFactoryStorage{
        uint256 reentrancyLock;
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

    // NOTE: This function is to be called once only
    modifier onlyInitializing() {
        LibInitializable.checkInitializing();
        _;
    }

    function initialize(address admin) external onlyInitializing {
        GenericFactoryStorage storage $ = getStorage();
        emit GenericFactoryGenesis();
        if (admin == address(0x00)) revert GenericFactoryBadAddress();
        LibAccessControl.grantRole(UPGRADE_ADMIN_ROLE, admin);
        
        emit GenericFactorySetUpgradeAdmin(admin);

    }

    modifier nonReentrant {
        LibNonReentrancy.enter();
        _;
        LibNonReentrancy.exit();
    }

    modifier adminOnly(){
        LibAccessControl.requireRole(UPGRADE_ADMIN_ROLE, msg.sender);
        _;
    }

    
    // NOTE: If modifier is not allowed on library. This shoudl warn
    // the facet using this library needs to use nonReentrant modifier
    // on function calling createProxy  from library
    function createProxy(address desiredImplementation, bool upgradeable, bytes memory trailingData)
        internal
        nonReentrant
        returns (address)
    {
        GenericFactoryStorage storage $ = getStorage();
        address _implementation = $.implementation;


        if (desiredImplementation == address(0x00)) desiredImplementation = _implementation;

        if (desiredImplementation == address(0x00) || desiredImplementation != _implementation) revert GenericFactoryImplementation();
        
        bytes memory prefixTrailingData = abi.encodePacked(bytes4(0x00), trailingData);
        
        address proxy;

        if (upgradeable) {
            proxy = address(new BeaconProxy(prefixTrailingData));
        } else {
            proxy = LibMetaProxyDeployer.deployMetaProxy(desiredImplementation, prefixTrailingData);
        }

        $.proxyLookup[proxy] =
            ProxyConfig({upgradeable: upgradeable, implementation: desiredImplementation, trailingData: trailingData});

        $.proxyList.push(proxy);

        IComponent(proxy).initialize(msg.sender);

        emit GenericFactoryProxyCreated(proxy, upgradeable, desiredImplementation, trailingData);

        return proxy;

    }

    function setImplementation(address newImplementation) internal nonReentrant adminOnly {
        GenericFactoryStorage storage $ = getStorage();
        if (newImplementation.code.length == uint256(0x00)) revert GenericFactoryBadAddress();
        $.implementation = newImplementation;
        emit GenericFactorySetImplementation(newImplementation);
    }

    function setUpgradeAdmin(address newUpgradeAdmin) internal nonReentrant adminOnly {
        GenericFactoryStorage storage $ = getStorage();
        
        $.upgradeAdmin = newUpgradeAdmin;
        
        emit GenericFactorySetUpgradeAdmin(newUpgradeAdmin);
    }

    // TODO: Missing more functions




}