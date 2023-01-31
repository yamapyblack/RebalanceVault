import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import { Addresses, Verify } from "../common";

const main = async () => {
  const a = Addresses()!;
  const inputTick = BigNumber.from("-202682");

  await Verify(a.VaultV1, [a.UniPool, inputTick]);
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
