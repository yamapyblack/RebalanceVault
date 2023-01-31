import { BigNumber } from "ethers";
import env from "hardhat";

export const NilAddress = "0x0000000000000000000000000000000000000000";
export const MAX_UINT256 = BigNumber.from("2").pow(BigNumber.from("256")).sub(BigNumber.from("1"));

export interface AddressesType {
  Deployer: string;
  Weth: string;
  Usdc: string;
  UniPool: string;
  VaultV1: string;
}

export const Addresses = () => {
  switch (env.network.name) {
    case "arb":
      return {
        Deployer: "",
        Weth: "0x82aF49447D8a07e3bd95BD0d56f3241523fBab1",
        Usdc: "0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8",
        UniPool: "0x17c14D2c404D167802b16C450d3c99F88F2c4F4d",
        VaultV1: "",
      } as AddressesType;

    default:
      return undefined;
  }
};

export const Verify = async (address: string, args: any[]) => {
  try {
    await env.run("verify:verify", {
      address: address,
      constructorArguments: args,
    });
  } catch (e: any) {
    if (e.message === "Missing or invalid ApiKey") {
      console.log("Skip verifing with", e.message);
      return;
    }
    if (e.message === "Contract source code already verified") {
      console.log("Skip verifing with", e.message);
      return;
    }
    throw e;
  }
};
