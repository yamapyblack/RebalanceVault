import { ethers } from "hardhat";
import { Addresses } from "../common";
import { BigNumber } from "ethers";

async function main() {
  const a = Addresses()!;

  const inputTick = BigNumber.from("-202682");

  const VaultV1 = await ethers.getContractFactory("VaultV1");
  const c0 = await VaultV1.deploy(a.UniPool, inputTick);
  await c0.deployed();
  console.log("deployed to:", c0.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
