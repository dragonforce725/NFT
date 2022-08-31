const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory("MyEpicGame");
    const gameContract = await gameContractFactory.deploy(
        ["Eevee", "Arcanaine", "Blastoise"],
            ["https://img.pokemondb.net/artwork/large/eevee.jpg",
            "https://assets.pokemon.com/assets/cms2/img/pokedex/full/059.png",
            "https://img.joomcdn.net/6dbd7c1686d1d52555772ad0c8bcc2cd191ea9b6_original.jpeg"],
                [300, 800, 1000], //HP
                    [50, 300, 200] // ATK
    );
    let txn;

    txn = await gameContract.mintCharacterNFT(2);
    await txn.wait();

    let returnedTokenUri = await gameContract.tokenURI(1);
    console.log("Token URI:", returnedTokenUri);
    
    await gameContract.deployed();
    console.log("Contrato implantado no endereco: ", gameContract.address);
    
};

const runMain = async () => {
    try{
        await main();
        process.exit(0);
    } catch (error) {
        console.log (error);
        process.exit(1);
    }
};

runMain();