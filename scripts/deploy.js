const hre = require("hardhat");

async function main() {
  const GuildChain = await hre.ethers.getContractFactory("GuildChain");
  const guildChain = await GuildChain.deploy();

  await guildChain.deployed();
  console.log("GuildChain contract deployed to:", guildChain.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
