import { ethers } from "hardhat";
import { Addresses, MAX_UINT256 } from "../common";
import { IERC20 } from "../../typechain-types/@openzeppelin/contracts/token/ERC20/IERC20";

async function main() {
  const a = Addresses()!;
  let tx;

  const weth = (await ethers.getContractAt("IERC20", a.Weth)) as IERC20;
  const usdc = (await ethers.getContractAt("IERC20", a.Usdc)) as IERC20;
  const wethAmount = MAX_UINT256;
  const usdcAmount = MAX_UINT256;

  //approve
  tx = await weth.approve(a.VaultV1, wethAmount);
  tx.wait();
  console.log("weth.approve", tx);
  tx = await usdc.approve(a.VaultV1, usdcAmount);
  tx.wait();
  console.log("usdc.approve", tx);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
