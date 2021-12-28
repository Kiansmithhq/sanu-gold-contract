// const ethers = require('ethers')

async function main () {
    // We get the contract to deploy
    const Sanu = await ethers.getContractFactory('SanuGold');
    console.log('Deploying Sanu Gold...');
    const sanu = await Sanu.deploy();
    await sanu.deployed();
    console.log('SNG deployed to:', sanu.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });