// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import "./InitializableMod.sol" as InitializableMod;

library LibInitializable{
    error Uninitialized();
    error InvalidInitialization();
    error InitializableNotInitializing();
    event Initialized(uint64 version);
    
    modifier initializer() {
        // solhint-disable-next-line var-name-mixedcase
        InitializableMod.InitializableStorage storage $ = InitializableMod.getStorage();

        // Cache values to avoid duplicated sloads
        bool isTopLevelCall = !$._initializing;
        uint64 initialized = $._initialized;

        // Allowed calls:
        // - initialSetup: the contract is not in the initializing state and no previous version was
        //                 initialized
        // - construction: the contract is initialized at version 1 (no reinitialization) and the
        //                 current contract is just being deployed
        bool initialSetup = initialized == 0 && isTopLevelCall;
        bool construction = initialized == 1 && address(this).code.length == 0;

        if (!initialSetup && !construction) {
            revert InvalidInitialization();
        }

        $._initialized = 1;
        if (isTopLevelCall) {
            $._initializing = true;
        }
        _;
        if (isTopLevelCall) {
            $._initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint64 version) {
        // solhint-disable-next-line var-name-mixedcase
        InitializableMod.InitializableStorage storage $ = InitializableMod.getStorage();

        if ($._initializing || $._initialized >= version) {
            revert InvalidInitialization();
        }

        $._initialized = version;
        $._initializing = true;
        _;
        $._initializing = false;
        emit Initialized(version);
    }
    
    
    modifier onlyInitializing() {
       InitializableMod.checkInitializing();
        _;
    }

    modifier onlyInitialized(){
        if (InitializableMod.getInitializedVersion() < uint256(0x01)) revert Uninitialized();
        _;
    
        _;
    }



}