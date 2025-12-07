// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;


uint256 constant REENTRANCYLOCK__UNLOCKED = 1;
uint256 constant REENTRANCYLOCK__LOCKED = 2;

// State

/// @title ProxyConfig
/// @notice This struct is used to store the configuration of a proxy deployed by the factory
struct ProxyConfig {
    // If true, proxy is an instance of the BeaconProxy
    bool upgradeable;
    // Address of the implementation contract
    // May be an out-of-date value, if upgradeable (handled by getProxyConfig)
    address implementation;
    // The metadata attached to every call passing through the proxy
    bytes trailingData;
}

bytes32 constant GENERIC_FACTORY_POSITION = keccak256("compose-extension.generic-factory");

struct GenericFactoryStorage{
    address upgradeAdmin;
    address implementation;
    mapping(address proxy => ProxyConfig) proxyLookup;
    address[] proxyList;

}

function getStorage() pure returns (GenericFactoryStorage storage s) {
    bytes32 position = GENERIC_FACTORY_POSITION;
    assembly {
        s.slot := position
    }
}

function upgradeAdmin() returns(address){
    GenericFactoryStorage storage $ = getStorage();
    return $.upgradeAdmin;
}

function implementation() returns(address){
    GenericFactoryStorage storage $ = getStorage();
    return $.implementation;
}

function proxyLookup(address proxy) returns(ProxyConfig memory){
    GenericFactoryStorage storage $ = getStorage();
    return $.proxyLookup[proxy];
}

function proxyList() returns(address[] memory){
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



// Proxy getters

/// @notice Get current proxy configuration
/// @param proxy Address of the proxy to query
/// @return config The proxy's configuration, including current implementation
function getProxyConfig(address proxy) returns (ProxyConfig memory config) {
    GenericFactoryStorage storage $ = getStorage();
    config = $.proxyLookup[proxy];
    if (config.upgradeable) config.implementation = $.implementation;
}

/// @notice Check if an address is a proxy deployed with this factory
/// @param proxy Address to check
/// @return True if the address is a proxy
function isProxy(address proxy) returns (bool) {
    GenericFactoryStorage storage $ = getStorage();
    return $.proxyLookup[proxy].implementation != address(0);
}

/// @notice Fetch the length of the deployed proxies list
/// @return The length of the proxy list array
function getProxyListLength() returns (uint256) {
    GenericFactoryStorage storage $ = getStorage();
    return $.proxyList.length;
}

/// @notice Get a slice of the deployed proxies array
/// @param start Start index of the slice
/// @param end End index of the slice
/// @return list An array containing the slice of the proxy list
function getProxyListSlice(uint256 start, uint256 end) returns (address[] memory list) {
    GenericFactoryStorage storage $ = getStorage();
    
    // TEMPORARY: Commented out to test if type(uint256).max causes compiler error
    // if (end == type(uint256).max) end = $.proxyList.length;
    uint256 maxUint = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    if (end == maxUint) end = $.proxyList.length;
    if (end < start || end > $.proxyList.length) revert E_BadQuery();

    list = new address[](end - start);
    for (uint256 i; i < end - start; ++i) {
        list[i] = $.proxyList[start + i];
    }
}

