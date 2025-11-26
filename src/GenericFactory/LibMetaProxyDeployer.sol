// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.30;



library LibMetaProxyDeployer{
    error MetaProxyDeployerDeploymentFailed();

    // Meta proxy bytecode from EIP-3488 https://eips.ethereum.org/EIPS/eip-3448
    bytes constant BYTECODE_HEAD = hex"600b380380600b3d393df3363d3d373d3d3d3d60368038038091363936013d73";
    bytes constant BYTECODE_TAIL = hex"5af43d3d93803e603457fd5bf3";



    function deployMetaProxy(address targetContract, bytes memory metadata) internal returns (address addr){
        bytes memory code = abi.encodePacked(BYTECODE_HEAD, targetContract, BYTECODE_TAIL, metadata);

        assembly ("memory-safe") {
            addr := create(0, add(code, 32), mload(code))
        }

        if (addr == address(0)) revert MetaProxyDeployerDeploymentFailed();

    }
}