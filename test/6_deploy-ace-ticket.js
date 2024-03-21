const fs = require("fs-extra");
const path = require("path");
const { ethers } = require("hardhat");

async function main() {
  const variablesPath = path.join(__dirname, "..", "..", "contracts.json");
  const data = JSON.parse(fs.readFileSync(variablesPath, "utf8"));
  const networkName = hre.network.name;
  const networkData = data[networkName];

  // Carregar o contrato GamesHub
  const GamesHub = await ethers.getContractFactory("GamesHub");
  const gamesHub = await GamesHub.attach(networkData.GAMES_HUB);
  console.log(`GamesHub loaded at ${gamesHub.address}`);

  // Deploy do AceTicket8, se necessário
  const name = "ACE_TICKET";

  if (networkData.NFT_BRACKETS === "") {
    const AceTicket8 = await ethers.getContractFactory("AceTicket8");
    const aceTicket8 = await AceTicket8.deploy(gamesHub.address);
    await aceTicket8.deployed();
    console.log(`AceTicket8 deployed at ${aceTicket8.address}`);

    networkData.NFT_BRACKETS = aceTicket8.address;
    fs.writeFileSync(variablesPath, JSON.stringify(data, null, 2));

    await new Promise((resolve) => setTimeout(resolve, 5000));

    console.log(`Setting AceTicket8 address to GamesHub...`);
    await gamesHub.setGameContact(
      aceTicket8.address,
      ethers.utils.id(name),
      true
    );

    await new Promise((resolve) => setTimeout(resolve, 5000));
  } else {
    console.log(`AceTicket8 already deployed at ${networkData.NFT_BRACKETS}`);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
