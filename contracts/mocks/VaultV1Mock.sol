// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import {VaultV1} from "../core/VaultV1.sol";

contract VaultV1Mock is VaultV1 {
    constructor(address _pool) VaultV1(_pool) {}

    function getNewTicks(int24 _currentTick) external view returns (int24, int24) {
        return _getNewTicks(_currentTick);
    }

    function checkSlippage(uint160 _currentSqrtRatioX96, bool _zeroForOne)
        external
        view
        returns (uint160 _swapThresholdPrice)
    {
        return _checkSlippage(_currentSqrtRatioX96, _zeroForOne);
    }
}
