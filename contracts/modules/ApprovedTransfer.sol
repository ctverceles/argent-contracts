// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.6.9;

import "./common/Utils.sol";
import "./common/BaseTransfer.sol";

/**
 * @title ApprovedTransfer
 * @dev Module to transfer tokens (ETH or ERC20) with the approval of guardians.
 * @author Julien Niset - <julien@argent.im>
 */
contract ApprovedTransfer is BaseTransfer {

    bytes32 constant NAME = "ApprovedTransfer";

    constructor(IModuleRegistry _registry, IGuardianStorage _guardianStorage) BaseModule(_registry, _guardianStorage, NAME) public {

    }

    /**
    * @dev transfers tokens (ETH or ERC20) from a wallet.
    * @param _wallet The target wallet.
    * @param _token The address of the token to transfer.
    * @param _to The destination address
    * @param _amount The amoutnof token to transfer
    * @param _data  The data for the transaction (only for ETH transfers)
    */
    function transferToken(
        address _wallet,
        address _token,
        address _to,
        uint256 _amount,
        bytes calldata _data
    )
        external
        onlyModule(_wallet)
        onlyWhenUnlocked(_wallet)
    {
        doTransfer(_wallet, _token, _to, _amount, _data);
    }

    /**
    * @dev call a contract.
    * @param _wallet The target wallet.
    * @param _contract The address of the contract.
    * @param _value The amount of ETH to transfer as part of call
    * @param _data The encoded method data
    */
    function callContract(
        address _wallet,
        address _contract,
        uint256 _value,
        bytes calldata _data
    )
        external
        onlyModule(_wallet)
        onlyWhenUnlocked(_wallet)
    {
        require(!IWallet(_wallet).authorised(_contract) && _contract != _wallet, "AT: Forbidden contract");
        doCallContract(_wallet, _contract, _value, _data);
    }

    /**
    * @dev lets the owner do an ERC20 approve followed by a call to a contract.
    * The address to approve may be different than the contract to call.
    * We assume that the contract does not require ETH.
    * @param _wallet The target wallet.
    * @param _token The token to approve.
    * @param _spender The address to approve.
    * @param _amount The amount of ERC20 tokens to approve.
    * @param _contract The contract to call.
    * @param _data The encoded method data
    */
    function approveTokenAndCallContract(
        address _wallet,
        address _token,
        address _spender,
        uint256 _amount,
        address _contract,
        bytes calldata _data
    )
        external
        onlyModule(_wallet)
        onlyWhenUnlocked(_wallet)
    {
        require(!IWallet(_wallet).authorised(_contract) && _contract != _wallet, "AT: Forbidden contract");
        doApproveTokenAndCallContract(_wallet, _token, _spender, _amount, _contract, _data);
    }

    /**
    * @dev Implementation of the getRequiredSignatures from the IModule interface.
    * @param _wallet The target wallet.
    * @param _data The data of the relayed transaction.
    * @return The number of required signatures and the wallet owner signature requirement.
    */
    function getRequiredSignatures(address _wallet, bytes calldata _data) external view override returns (uint256, OwnerSignature) {
        // owner  + [n/2] guardians
        uint numberOfSignatures = 1 + Utils.ceil(guardianStorage.guardianCount(_wallet), 2);
        return (numberOfSignatures, OwnerSignature.Required);
    }
}