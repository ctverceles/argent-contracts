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

import "./common/BaseModule.sol";

/**
 * @title SimpleUpgrader
 * @dev Temporary module used to add/remove other modules.
 * @author Olivier VDB - <olivier@argent.xyz>, Julien Niset - <julien@argent.im>
 */
contract SimpleUpgrader is BaseModule {

    bytes32 constant NAME = "SimpleUpgrader";
    address[] public toDisable;
    address[] public toEnable;

    // *************** Constructor ********************** //

    constructor(
        IModuleRegistry _registry,
        address[] memory _toDisable,
        address[] memory _toEnable
    )
        BaseModule(_registry, IGuardianStorage(0), NAME)
        public
    {
        toDisable = _toDisable;
        toEnable = _toEnable;
    }

    // *************** External/Public Functions ********************* //

    /**
     * @dev Perform the upgrade for a wallet. This method gets called
     * when SimpleUpgrader is temporarily added as a module.
     * @param _wallet The target wallet.
     */
    function init(address _wallet) public override onlyWallet(_wallet) {
        uint256 i = 0;
        //add new modules
        for (; i < toEnable.length; i++) {
            IWallet(_wallet).authoriseModule(toEnable[i], true);
        }
        //remove old modules
        for (i = 0; i < toDisable.length; i++) {
            IWallet(_wallet).authoriseModule(toDisable[i], false);
        }
        // SimpleUpgrader did its job, we no longer need it as a module
        IWallet(_wallet).authoriseModule(address(this), false);
    }

    /**
    * @dev Implementation of the getRequiredSignatures from the IModule interface.
    * The method should not be called and will always revert.
    * @param _wallet The target wallet.
    * @param _data The data of the relayed transaction.
    * @return always reverts.
    */
    function getRequiredSignatures(address _wallet, bytes calldata _data) external virtual override view returns (uint256, OwnerSignature) {
        revert("RM: disabled method");
    }
}