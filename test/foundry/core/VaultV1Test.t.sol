// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../AddressHelper.sol";
import {Ints} from "../Ints.sol";

import {VaultV1Mock} from "../../../contracts/mocks/VaultV1Mock.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract VaultV1Test is Test {
    using stdStorage for StdStorage;
    using Ints for int24;

    address alice = vm.addr(1);
    address bob = vm.addr(2);
    address carol = vm.addr(3);

    AddressHelper.TokenAddr tokenAddr;
    AddressHelper.UniswapAddr uniswapAddr;
    ISwapRouter router;
    address dedicatedMsgSender;

    VaultV1Mock vault;
    IUniswapV3Pool pool;
    IERC20 weth;
    IERC20 usdc;

    int24 baseTick = 0;

    function setUp() public {
        vm.label(alice, "alice");
        vm.label(bob, "bob");
        vm.label(carol, "carol");

        (tokenAddr, uniswapAddr) = AddressHelper.addresses(block.chainid);

        router = ISwapRouter(uniswapAddr.routerAddr); //for test
        pool = IUniswapV3Pool(uniswapAddr.wethUsdcPoolAddr);
        weth = IERC20(tokenAddr.wethAddr);
        usdc = IERC20(tokenAddr.usdcAddr);

        (uint160 _sqrtRatioX96, int24 _tick, , , , , ) = pool.slot0();
        baseTick = _tick;
        // console2.log(baseTick.toString(), "baseTick");

        vm.prank(alice);
        vault = new VaultV1Mock(address(pool));
        dedicatedMsgSender = vault.dedicatedMsgSender();

        //deal
        deal(tokenAddr.wethAddr, address(this), 10_000 ether);
        deal(tokenAddr.usdcAddr, address(this), 10_000_000 * 1e6);
        deal(tokenAddr.wethAddr, alice, 10_000 ether);
        deal(tokenAddr.usdcAddr, alice, 10_000_000 * 1e6);

        //approve
        usdc.approve(address(router), type(uint256).max);
        weth.approve(address(router), type(uint256).max);
        vm.startPrank(alice);
        usdc.approve(address(vault), type(uint256).max);
        weth.approve(address(vault), type(uint256).max);
        vm.stopPrank();
    }

    function test_depostRevert() public {
        vm.expectRevert(bytes("InvalidDepositSender"));
        vault.deposit(10 ether, 10_000 * 1e6, baseTick);
    }

    function test_depost() public {
        vm.prank(alice);
        vault.deposit(10 ether, 10_000 * 1e6, baseTick);
        consoleUnderlyingBalances();
    }

    function test_redeemRevert() public {
        vm.prank(alice);
        vault.deposit(10 ether, 10_000 * 1e6, baseTick);
        vm.expectRevert(bytes("InvalidRedeemSender"));
        vault.redeem(baseTick);
    }

    function test_redeem() public {
        vm.prank(alice);
        vault.deposit(10 ether, 10_000 * 1e6, baseTick);
        vm.prank(alice);
        vault.redeem(baseTick);
        consoleUnderlyingBalances();
    }

    function test_rebalanceRevert() public {
        vm.expectRevert(bytes("Only dedicated msg.sender"));
        vault.rebalance(-205680, -203760);
    }

    function test_rebalance() public {
        vm.prank(alice);
        vault.deposit(10 ether, 10_000 * 1e6, baseTick);
        vm.prank(dedicatedMsgSender);
        vault.rebalance(-205680, -203760);
    }

    function test_newTicks() public {
        (int24 _newLowerTick, int24 _newUpperTick) = vault.getNewTicks(baseTick);
        console2.log(_newLowerTick.toString(), "newLowerTick");
        console2.log(_newUpperTick.toString(), "newUpperTick");
    }

    function test_scenario() public {
        vm.prank(alice);
        vault.deposit(10 ether, 10_000 * 1e6, baseTick);
        swap(true, 100 ether);
        swap(false, 130000 * 1e6);
        consoleUnderlyingBalances();
        vm.prank(alice);
        vault.redeem(baseTick);
        consoleUnderlyingBalances();
        console2.log(weth.balanceOf(alice), "weth balanceOf");
        console2.log(usdc.balanceOf(alice), "usdc balanceOf");
    }

    /* ========== TEST FUNCTIONS ========== */
    function consoleUnderlyingBalances() private {
        (
            uint256 amount0,
            uint256 amount1,
            uint256 fees0,
            uint256 fees1,
            uint256 amount0Balance,
            uint256 amount1Balance
        ) = vault.getUnderlyingBalances();
        console2.log("==============consoleUnderlyingBalances");
        console2.log(amount0, "amount0");
        console2.log(amount1, "amount1");
        console2.log(fees0, "fees0");
        console2.log(fees1, "fees1");
        console2.log(amount0Balance, "amount0Balance");
        console2.log(amount1Balance, "amount1Balance");
        console2.log("============== end consoleUnderlyingBalances");
    }

    function swap(bool _zeroForOne, uint256 _amountIn) private {
        ISwapRouter.ExactInputSingleParams memory params;
        if (_zeroForOne) {
            params = ISwapRouter.ExactInputSingleParams({
                tokenIn: address(weth),
                tokenOut: address(usdc),
                fee: 3000,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: _amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
        } else {
            params = ISwapRouter.ExactInputSingleParams({
                tokenIn: address(usdc),
                tokenOut: address(weth),
                fee: 3000,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: _amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
        }
        router.exactInputSingle(params);
    }

    // function swap(
    //     bool zeroForOne,
    //     int256 amountSpecified,
    //     uint160 sqrtPriceLimitX96
    // ) private {
    //     pool.swap(address(this), zeroForOne, amountSpecified, vault.checkSlippage(sqrtPriceLimitX96, zeroForOne), "");
    // }

    // function uniswapV3SwapCallback(
    //     int256 amount0Delta,
    //     int256 amount1Delta,
    //     bytes calldata /*data*/
    // ) external {
    //     if (msg.sender != address(pool)) {
    //         revert("CallbackCaller");
    //     }

    //     if (amount0Delta > 0) {
    //         weth.transfer(msg.sender, uint256(amount0Delta));
    //     } else if (amount1Delta > 0) {
    //         usdc.transfer(msg.sender, uint256(amount1Delta));
    //     }
    // }
}
