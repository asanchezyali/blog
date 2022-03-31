# ¿Cómo crear un NFT en Solana con IPFS?


Los NFTs son mucho más que images generadas aleatoriamente, esto promete ser la revolución en los títulos de propiedad digital en la web tal y como la conocemos. Si quieres aprender más acerca de esto, te recomiendo leer el articulo de Nick Szabo, [_Secure Property Titles with Owner Authority_](https://nakamotoinstitute.org/secure-property-titles/), allí encontrarás las primeras ideas acerca de todo este asunto de los NFTs.

A continuación vamos a ver cómo crear una colección de NFTs en Solana usando Pinata e IPFS. Este es un tutorial especialmente interesante porque Solana ha estado estrechamente vinculado Arweave, pero muchos proyectos prefieren IPFS por su rápido acceso al contenido y su fiabilidad. Metaplex, es un proyecto construido para hacer más fácil la creación de proyectos NFT en Solana y tiene soporte para IPFS, y esto incluye la capacidad para usar Pinata para almacenar contenido y servir este contenido a través de una puerta de enlace IPFS dedicada. 

## Configuración del ambiente de trabajo

Para empezar, asegúrate de registrarte en [Pinata](https://www.pinata.cloud/). Usted puede hacer pruebas con una cuenta gratuita, pero para el lanzamiento de NFTs en la red principal, debes considerar el plan professional con una puerta de enlace IPFS dedicada. 

Una vez que te hayas inscrito en una cuenta, sólo tienes que asegurarte de que tienes instalados los siguientes elementos (cada uno de ellos está vinculado a las instrucciones de instalación en caso de que tengas que instalarlos):

* [Node.js](https://nodejs.org/en/download/) - version 16.13.0 o la más reciente.
* [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) - versión 2.32.0 o la más reciente.
* [Yarn](https://classic.yarnpkg.com/lang/en/docs/install/#mac-stable) - versión 1.22.17 o la más reciente.
* [ts-node](https://www.npmjs.com/package/ts-node#installation) - versión 10.4.0 o la más reciente.
* [Solana CLI](https://docs.solana.com/cli/install-solana-cli-tools) - version 1.8.16 o la más reciente.

Por si sirve de algo, seguiremos gran parte de las instrucciones de la página web de [Metaplex](https://docs.metaplex.com/candy-machine-v2/getting-started) con algunas modificaciones que nos permitan subir contenidos a IPFS a través de Pinata.

## Preparando los activos

Este tutorial no va a pasar por el proceso de generar los activos para su proyecto  de NFTs. Ese es un esfuerzo totalmente separado que tiene que ocurrir antes de que el contrato puede ser desplegado en Solana. Así que, asumiendo que usted ya tiene las imágenes creadas, vamos a ver cómo prepararlas para subirlas a IPFS a través de Metaplex.

El primer paso es crear una carpeta para los activos de su proyecto NFT. Desde la línea de comandos, que se verá así:

```shell
mkdir nft-project
```

Dentro de esa carpeta, crea otra carpeta llamada `assets`. En la carpeta `assets`, añadirás todas tus imágenes. Es importante que cada una de tus imágenes esté etiquetada en un formato de índice base 0. Eso significa que la primera imagen sería `0.png` y la segunda sería `1.png` y así sucesivamente.

Una vez que sus imágenes estén en la carpeta, tendrá que crear los metadatos para estas imágenes. Si tiene alguna experiencia con los metadatos NFT de Ethereum, se sentirá como en casa con los metadatos NFT de Solana. La estructura es casi idéntica. Echemos un vistazo a una estructura básica de archivo de metadatos JSON para NFTs en Solana:

```json
{
    "name": "Number #0001",
    "symbol": "NB",
    "description": "Collection of 10 numbers on the blockchain. This is the number 1/10.",
    "image": "0.png",
    "attributes": [
        {"trait_type": "Layer-1", "value": "0"},
        {"trait_type": "Layer-2", "value": "0"}, 
        {"trait_type": "Layer-3", "value": "0"},
        {"trait_type": "Layer-4", "value": "1"}
    ],
    "properties": {
        "creators": [{"address": "N4f6zftYsuu4yT7icsjLwh4i6pB1zvvKbseHj2NmSQw", "share": 100}],
        "files": [{"uri": "0.png", "type": "image/png"}]
    },
    "collection": {"name": "numbers", "family": "numbers"}
}
 ```

 Al igual que con el estándar de metadatos de Ethereum, el estándar de metadatos de Solana tiene un nombre, una imagen y una descripción. Además, se pueden incluir atributos (al igual que con ETH), un símbolo y detalles de cobro. En los proyectos de Ethereum, el símbolo del token se asigna generalmente en la implementación del contrato y no en los metadatos. Otra diferencia es la parte de propiedades de los metadatos de Solana. Esto es necesario y le permite incluir una serie de archivos para sus NFT. Tiene que tener al menos un archivo en esa matriz que apunte al mismo activo que la propiedad de la imagen, pero puede incluir otros archivos que conformen su NFT completa. Este es un concepto realmente interesante que debe ser explorado más a fondo, pero por el bien de este post, sólo vamos a operar con NFTs de un solo activo.

Si desea profundizar en la norma de los metadatos de Solana para los NFTs, puede hacerlo [aquí](https://docs.metaplex.com/candy-machine-v2/preparing-assets).

Ahora que tenemos las imágenes en la carpeta. Sabemos que esas imágenes necesitan ser nombradas de una manera específica. Y sabemos que necesitamos archivos de metadatos JSON. ¿Cómo vamos a conseguir ahora esos archivos JSON creados y añadidos a la carpeta de activos. Podrías hacerlo manualmente, pero con un proyecto de 10.000 NFT, eso sería casi imposible.

Vamos a escribir un script para crear los archivos de metadatos.

Desde tu línea de comandos, asegúrate de que estás en la carpeta `nft-project`. Crearemos un nuevo archivo llamado `metadata-generator.js` ejecutando este comando: `touch metadata-generator.js`.

En tu editor de código, abre ese nuevo archivo. Está vacío, pero lo rellenaremos ahora. Tenemos que recorrer todas las imágenes en nuestra carpeta de activos y crear un único archivo JSON para cada uno. Necesitamos nombrar y guardar ese archivo JSON en la misma carpeta de activos. Para hacer esto, haremos uso del Node.js `fs` que está incorporado en Node.js.

En su archivo `metadata-generator.js` añada este código:

```javascript
const fs = require('fs');
const imageDir = fs.readdirSync("./assets");
imageDir.forEach(img => {
  const metadata = {
    name: `Image ${img.split(".")[0]}`,
    description: "An image in the NFT collection",
    symbol: "YOUR_NFT_COLLECTION_SHORT_SYMBOL",
    image: img,
    seller_fee_basis_points: "ROYALTIES_PERCENTAGE_BASIS_POINTS",
    properties: {
      files: [{ uri: img, "type": "image/png" }],
      category: "image",
      creators: [{
        address: "YOUR_SOL_WALLET_ADDRESS",
        share: 100
      }]
    }
  }
  fs.writeFileSync(`./assets/${img.split(".")[0]}.json`, JSON.stringify(metadata))
});
```

Por supuesto, usted podría personalizar esto para su proyecto. Dar a sus imágenes diferentes nombres, añadir la matriz de atributos, etc. Este es un ejemplo muy básico, pero te servirá para empezar.

Para ejecutar tu script y generar los metadatos, debes ejecutar este comando desde la raíz de tu carpeta de proyecto: `node metadata-generator.js`.

Cuando el script esté terminado, tendrás una carpeta de activos que tiene imágenes y archivos JSON juntos. Debería tener este aspecto:
```shell
tree

# Output
.
├── assets
│   ├── 0.json
│   ├── 0.png
│   ├── 1.json
│   ├── 1.png
│   ├── 2.json
│   └── 2.png
└── metadata-generator.js
```

Bien, ya tenemos nuestros activos listos para empezar. Es hora de empezar a usar Metaplex para ponernos en marcha con Solana.

## Metaplex

[Metaplex](https://www.metaplex.com/) es una herramienta que facilita el lanzamiento de un proyecto NFT en Solana. En lugar de tener que escribir tu propio contrato inteligente como tendrías que hacer con Ethereum, Metaplex tiene contratos pre-escritos que los proyectos pueden conectar. Para que esto funcione, Metaplex tiene que ser capaz de acceder a los archivos asociados a los NFTs, luego tiene que ser capaz de subir esos archivos y asociarlos a cada token que se va a acuñar.

Metaplex tiene soporte para IPFS a través de algunos servicios, pero nos centraremos en el uso de Pinata.

Vamos a seguir la guía estándar de Metaplex Candy Machine que se encuentra [aquí](https://docs.metaplex.com/candy-machine-v2/getting-started). El primer paso va a ser clonar Metaplex. Ejecute el siguiente comando en su terminal:

```shell
git clone https://github.com/metaplex-foundation/metaplex.git ~/metaplex
```

Estamos clonando el directorio en el directorio `home` para que no tengamos que recordar dónde se clonó el proyecto. Dentro del nuevo repositorio de metaplex hay un código para soportar la CLI de JavaScript que vamos a utilizar. Por lo tanto, tenemos que instalar las dependencias para ese código CLI.

```shell
yarn install --cwd ~/metaplex/js/
```

Ahora, asegurémonos de que la instalación ha funcionado. ¿Recuerdas que instalamos `ts-node`? Vamos a usar eso ahora para ejecutar un comando para el cli de metaplex

```shell
export candymachine=«YOUR_ROOT_PATH»/metaplex/js/packages/cli/src/candy-machine-v2-cli.ts
ts-node $candymachine --version

# Output
0.0.2
```

Esto debería imprimir una versión si todo fue instalado correctamente. Ahora, necesitamos asegurarnos de que el CLI de Solana está funcionando. Ejecute este comando para obtener el número de versión:

```shell
solana --version

# Output
solana-cli 1.8.16 (src:23af37fe; feat:188619054
```

Si eso funciona, está listo. Si no es así, comprueba que has instalado el [Solana CLI Toolkit](https://docs.solana.com/cli/install-solana-cli-tools). A continuación, vamos a utilizar ese CLI para crear la cartera `devnet`. El `devnet` de Solana es donde podemos experimentar sin temor a incurrir en ningún impacto financiero real.

Ejecute este comando para crear una nueva criptcartera de papel y almacenar las credenciales

```shell
solana-keygen new --outfile ~/.config/solana/«MY_WALLET_PAPER».json
```

Ahora, podemos establecer el par de claves por defecto para nuestras interacciones de Solana CLI:

```shell
solana config set --keypair ~/.config/solana/«MY_WALLET_PAPER».json
```

Por último, hagamos saber a la CLI que pretendemos interactuar con la devnet:

```shell 
solana config set --url devnet
```

Pora comprobar la configuración actual de la red (y otras) podemos emplear este comando:

```shell 
solana config get

# Output
Config File: /home/user/.config/solana/cli/config.yml
RPC URL: https://api.devnet.solana.com 
WebSocket URL: wss://api.devnet.solana.com/ (computed)
Keypair Path: /home/user/.config/solana/«MY_PAPER_WALLET».json 
Commitment: confirmed 
```

con el CLI podemos ver la dirección de nuestra criptocartera:

```shell
solana address

# Output is something like this:
4aDSG82CdgMwt81z7AwnLnDRZyp6MjvZMUVpT82HZRU9
```

A continuación vamos a conseguir algo de token de Solana, para hacer esto, asegurate de que te encuentras en la devnet, ya que nuestra dapp va funcionar en esta red. Para conseguir los tokens hacemos:

```shell
solana airdrop 2 4aDSG82CdgMwt81z7AwnLnDRZyp6MjvZMUVpT82HZRU9 --url devnet

# Output is something like this:
Requesting airdrop of 2 SOL

Signature: 3KsFBCULmso5Lc7CAQdqF8rzsBXb3xaVrG3cup19n3P2paw3ryvovWQ9MsMB8GMiQkXJWyHXGrni63BsNrxVfHP2

2 SOL
```

Para obtener la información completa de nuestra cuenta:
```shell
solana account «YOUR_ADDRESS»

# Output is something like this:
Public Key: 4aDSG82CdgMwt81z7AwnLnDRZyp6MjvZMUVpT82HZRU9
Balance: 4.956381584 SOL
Owner: 11111111111111111111111111111111
Executable: false
Rent Epoch: 277
```

Para verificar el balance de nuestro monedero hacemos:

```shell
solana balance 4aDSG82CdgMwt81z7AwnLnDRZyp6MjvZMUVpT82HZRU9

# Output
2 SOL
```

Hasta aquí hemos conseguido crear una criptocartera de papel y fondear con un 2 SOL, tokens que utilizaremos más adelante para probar nuestra aplicación. A continuación vamos a ver cómo podemos cambiar entre cada una de las redes de Solana (localhost, testnet, devnet y mainnet-beta).

## _Drop configuration_


## Patrocinio 
₿itcoin:

Solana:

Ethereum:

Paypal: alejandro.driveyali@gmail.com
## Imágenes

  - [Unplash](https://unsplash.com/) - [NTF inscription on cubes against the background of dollars and microcircuits](https://unsplash.com/photos/yscrM1AOEKI)

## Referencias

1. [Julius Berner. 2021. The Modern Mathematics of deep learning.](https://deepai.org/publication/the-modern-mathematics-of-deep-learning)
2. [Yaser Abu-Mostafa Data. 2012 - 2015. Learning From Data.](https://work.caltech.edu/telecourse)

3. [Web3.js](https://github.com/ChainSafe/web3.js)
4. [Metaboss](https://metaboss.rs/update.html)
