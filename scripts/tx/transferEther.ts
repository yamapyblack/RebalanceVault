import { ethers } from "hardhat";
import { KmsSigner } from "../common";

async function main() {
  const signer = KmsSigner();

  const amount = "0.0002";
  const tx = await signer.sendTransaction({
    to: "",
    value: ethers.utils.parseEther(amount),
  });
  console.log("tx:", tx);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
