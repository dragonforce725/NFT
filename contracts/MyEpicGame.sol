//SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

//Contarto NFT para herdar
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./libraries/Base64.sol";
import "hardhat/console.sol";

contract MyEpicGame is ERC721 {

    struct CharacterAttributes{
        uint characterIndex;
        string name;
        string imageURI;
        uint HP;
        uint maxHP;
        uint atk;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Uma pequena array vai nos ajudar a segurar os dados padrao dos
    // nossos personagens. Isso vai ajudar muito quando mintarmos nossos
    // personagens novos e precisarmos saber o HP, dano de ataque e etc.
    
    CharacterAttributes[] defaultCharacters;

    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    // Um mapping de um endereco => tokenId das NFTs, nos da um
    // jeito facil de armazenar o dono da NFT e referenciar ele
    // depois.
    mapping(address => uint256) public nftHolders;
    
    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint [] memory characterHP,
        uint [] memory characterAtk
    )
    // Esse eh o nome e o simbolo do nosso token
    ERC721("Heroes", "HERO")
    {
        // Faz um loop por todos os personagens e salva os valores deles no
        // contrato para que possamos usa-los depois para mintar as NFTs
        for(uint i = 0; i < characterNames.length; i += 1){
            defaultCharacters.push(CharacterAttributes({
                characterIndex: i,
                name: characterNames[i],
                imageURI: characterImageURIs[i],
                HP: characterHP[i],
                maxHP: characterHP[i],
                atk: characterAtk[i]
            }));

            CharacterAttributes memory c = defaultCharacters[i];
            console.log("personagem inicializado: %s com %s de HP, img %s", c.name, c.HP, c.imageURI);
        }
        _tokenIds.increment();
    }

    // Usuarios vao poder usar essa funcao e pegar a NFT baseado no personagem que mandarem!
    function mintCharacterNFT(uint _characterIndex) external{  
        uint256 newItemId = _tokenIds.current();
        
        // A funcao magica! Atribui o tokenID para o endereço da carteira de quem chamou o contrato.
        _safeMint(msg.sender, newItemId);

        // mapeamos o tokenId => os atributos dos personagens.
        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            HP: defaultCharacters[_characterIndex].HP,
            maxHP: defaultCharacters[_characterIndex].maxHP,
            atk: defaultCharacters[_characterIndex].atk
        });
        console.log("Mintou NFT c/ tokenId %s e characterIndex %s", newItemId, _characterIndex);

        //manter um jeito facil de ver qum possui a NFT
        nftHolders[msg.sender] = newItemId;

        //Incrementa o token para a proxima pessoa que utilizar.
        _tokenIds.increment();
    }

    function tokenURI(uint256 _tokenId) public view override returns(string memory){
        CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

        string memory strHP = Strings.toString(charAttributes.HP);
        string memory strMaxHP = Strings.toString(charAttributes.maxHP);
        string memory strAtk = Strings.toString(charAttributes.atk);

        string memory json = Base64.encode(
            abi.encodePacked(
            '{"name": "', 
            charAttributes.name,
            ' -- NFT #: ',
            Strings.toString(_tokenId),
            '", "description": "Esta NFT da acesso ao meu jogo NFT!", "image": "',
            charAttributes.imageURI,
            '", "attributes": [ {"trait_type": "Health Points", "value": ',strHP,', "max_value":',strMaxHP,'}, { "trait_type": "atk", "value": ', strAtk,'} ]}'
        )
    );

    string memory output = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

    return output;
}
}