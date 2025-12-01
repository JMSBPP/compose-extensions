// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.30;


interface IGenericFactory{
    struct ProxyConfig {
        // If true, proxy is an instance of the BeaconProxy
        bool upgradeable;
        // Address of the implementation contract
        // May be an out-of-date value, if upgradeable (handled by getProxyConfig)
        address implementation;
        // The metadata attached to every call passing through the proxy
        bytes trailingData;
    }

    function createProxy(address desiredImplementation, bool upgradeable, bytes memory trailingData) external;
    function setImplementation(address newImplementation) external;
    function setUpgradeAdmin(address newUpgradeAdmin) external;
    function getProxyConfig(address proxy) external view returns (ProxyConfig memory config);
    function isProxy(address proxy) external view returns (bool);
    function getProxyListLength() external view returns (uint256);
    function getProxyListSlice(uint256 start, uint256 end) external view returns (address[] memory list);
}

abstract contract GenericFactoryFacet is IGenericFactory{
    /// @dev Storage position determined by the keccak256 hash of the diamond storage identifier.
    bytes32 constant STORAGE_POSITION = keccak256("compose.generic-factory");    
    
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

}

