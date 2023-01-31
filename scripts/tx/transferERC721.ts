import { ethers } from "hardhat";
import { KmsSigner, Addresses } from "../common";
import { IERC721 } from "../../typechain-types/@openzeppelin/contracts/token/ERC721/IERC721";

async function main() {
  const signer = KmsSigner();
  const a = Addresses()!;

  const contractAddress = "";
  const from = "";
  const to = "";
  const tokenId = 135141;
  //

  const contract = (await ethers.getContractAt("IERC721", contractAddress, signer)) as IERC721;
  const tx = await contract.connect(signer).transferFrom(from, to, tokenId);
  console.log(tx);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
