import { ethers } from "hardhat";
import { Addresses } from "../common";
import { IERC20 } from "../../typechain-types/@openzeppelin/contracts/token/ERC20/IERC20";

async function main() {
  const signer = KmsSigner();
  const a = Addresses()!;

  const contract = (await ethers.getContractAt("IERC20", a.Gmx, signer)) as IERC20;
  const amount = "6.146765287723434276";
  const tx = await contract
    .connect(signer)
    .transfer("", ethers.utils.parseEther(amount));
  console.log(tx);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
