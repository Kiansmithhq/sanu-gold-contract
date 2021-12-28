async function main () {
    // Our code will go here
    const accounts = await ethers.provider.listAccounts();
    // console.log(accounts);

    // const address = '0x5FbDB2315678afecb367f032d93F642f64180aa3';
    const address = "0x75463BC8216c3D1a7370d5b0215B243e440ed30c"
    const Sanu = await ethers.getContractFactory('SanuGold');
    const sanu = await Sanu.attach(address);

    // const init = await sanu.initialize("Sanu Gold", 'SGLD')
    // console.log("VALUE IS::: ", await sanu.decimals(), await sanu.symbol(), await sanu.name())
    // console.log("MINT TO ADDRESS", await sanu.mint("0x4c46e04bbc60decc6e4d321822a7a15e9cc45210", "625000000000000000000"))
    // console.log("MINT TO ADDRESS", await sanu.burn("500040000000000000000"))
    console.log('BURN FROM:::', await sanu.burnFrom("0x4c46e04bbc60decc6e4d321822a7a15e9cc45210", "349950000000000000000"))
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });