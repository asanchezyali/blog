---
weight: 1
title: ¿Cómo crear una colección de NFTs en Solana con IPFS?
date: 2022-03-23T08:19:27-05:00
draft: false
excerpt: ¿Cómo crear una colección NFT en Solana con IPFS?
hero: /images/ml-01.jpg
timeToRead: 4
authors:
  - Alejandro Sánchez Yalí
description: "Los NFTs son mucho más que imagenes generadas aleatoriamente, esto promete ser la revolución de la propiedad digital y la autoridad digital tal y como la conocemos actualmente. En este artículo vamos a explicar cómo crear un NFT en Solana con IPFS."
resources:
- name: "featured-image"
  src: "featured-image.webp"
tags:
  - Sistemas distribuidos

categories:
  - Blockchain
keywords:
  - Solana
  - NFT
  - Phantom Wallet
  

lightgallery: true
---

Los NFTs son mucho más que imágenes generadas aleatoriamente, esto promete ser la revolución de la propiedad digital y la autoridad digital tal y como la conocemos. Si quieres entender más sobre este concepto, te recomiendo leer el articulo de Nick Szabo, [_Secure Property Titles with Owner Authority_](https://nakamotoinstitute.org/secure-property-titles/), allí encontrarás algunas de las ideas que dieron origin a los NFTs. En este artículo vamos a explicar cómo crear una colección de  NFTs en Solana con IPFS. 

Este es un tutorial especialmente interesante porque Solana ha estado estrechamente vinculado [Arweave](https://www.arweave.org/), sin embargo, hay muchos proyectos prefieren usar IPFS para almacenar sus datos,  por su rápido acceso al contenido y su fiabilidad. Por otro lado, Metaplex, es un proyecto construido para hacer más fácil la creación de proyectos NFTs en Solana y tiene soporte para IPFS, esto incluye la capacidad para usar Pinata para almacenar contenido y servir este contenido a través de una _API Gateway_ dedicada a IPFS. 

## Configuración del ambiente de trabajo

Para empezar, te debes registrar en [Pinata](https://www.pinata.cloud/). Si lo que quieres es hacer pruebas, se puede usar la plan gratuito, sin embargo para el lanzamiento de una colección grande de NFTs en la red principal, la recomendación es considerar el plan professional con una _API Gateway_ dedicada a IPFS. 

Una vez que te hayas inscrito en Pinata, sólo tienes que asegurarte de que tienes instalados los siguientes elementos (cada uno de ellos está vinculado a las instrucciones de instalación en caso de que tengas que instalarlos):

* [Node.js](https://nodejs.org/en/download/) - version 16.13.0 o la más reciente.
* [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) - versión 2.32.0 o la más reciente.
* [Yarn](https://classic.yarnpkg.com/lang/en/docs/install/#mac-stable) - versión 1.22.17 o la más reciente.
* [ts-node](https://www.npmjs.com/package/ts-node#installation) - versión 10.4.0 o la más reciente.
* [Solana CLI](https://docs.solana.com/cli/install-solana-cli-tools) - version 1.8.16 o la más reciente.

Por si sirve de algo, seguiremos gran parte de las instrucciones de la página web de [Metaplex](https://docs.metaplex.com/candy-machine-v2/getting-started) con algunas modificaciones para subir contenido a IPFS a través de Pinata.

## Preparando los _assets_

En este tutorial no te voy a enseñar a generar los _assets_ para tu proyecto de NFTs. Ese es un trabajo totalmente separado que tiene que antes de desplegar el contrato en Solana. Así que, voy a asumir que ya tienes una colección imágenes para crear tus NFTs. A continuación, vamos a ver cómo prepararlas para subirlas a IPFS a través de Metaplex.

El primer paso es crear una carpeta para los _assets_ de su proyecto NFT. Desde la línea de comandos, ejecute el siguiente comando:

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

# Output is something like this:
2 SOL
```

Hasta aquí hemos conseguido crear una criptocartera de papel y fondear con un 2 SOL, tokens que utilizaremos más adelante para probar nuestra aplicación. A continuación vamos a ver cómo podemos cambiar entre cada una de las redes de Solana (localhost, testnet, devnet y mainnet-beta).

## Configuración de la colección NFT
Esta es la parte más importante de todo el desarrollo, por lo que podrás ver los detalles en la [documentación oficial](https://docs.metaplex.com/candy-machine-v2/configuration). Metaplex usan una herramienta llamada _Candy Machine_ para generar los NFT, y es importante asegurarse de que su proyecto esté perfectamente configurado. En la raíz de su proyecto, cree un archivo JSON llamado config.json. Luego, ingrese una configuración como esta:

```json
{
  "price": 0.05,
  "number": 3,
  "gatekeeper": null,
  "solTreasuryAccount": "YOUR_DEVNET_WALLET_ADDRESS",
  "splTokenAccount": null,
  "splToken": null,
  "goLiveDate": "01 Jan 2022 00:00:00 GMT",
  "endSettings": null,
  "whitelistMintSettings": null,
  "hiddenSettings": null,
  "storage": "pinata",
  "ipfsInfuraProjectId": null,
  "ipfsInfuraSecret": null,
  "pinataJwt": "YOUR_PINATA_JWT_TOKEN",
  "pinataGateway": "YOUR_PINATA_GATEWAY_URL",
  "awsS3Bucket": null,
  "noRetainAuthority": false,
  "noMutable": false
}
```

Esto puede parecer mucho, pero en realidad es sola configuración mínima requerida. Hay mucho más que puedes agregar. Sin embargo, no te preocupes. La matendremos simple. Solo se necesita cambiar cinco cosas en este archivo. El primer cambio es establecer la propiedad de `storage` para que apunte a `pinata`.

Luego, debe decidir si va a utilizar una [_Pinata Dedicated Gateway_](https://knowledge.pinata.cloud/en/articles/5666429-dedicated-gateways) o no. Si lo hace, le dará a usted y a cualquier persona que cargue sus NFT el mejor rendimiento posible. Pero, aunque se recomienda, no es obligatorio. Si se decide por una _Pinata Dedicated Gateway_, deberá actualizar su cuenta al [plan profesional](https://www.pinata.cloud/pricing) en _Pinata_.


A continuación, debe obtener un JWT para acceder a la API de _Pinata_. Para hacerlo, haga clic en el menú desplegable en la parte superior derecha, haga clic en _API Keys_, y luego genere una nueva _API key_. Puedes seleccionar los _endpoints_ específicos a los que la clave debe tener acceso (_pinFileToIPFS_) o puede convertirla en una clave de administrador que tenga acceso completo. Esto depende de sus preferencias de seguridad, pero la clave debe tener acceso a _pinFileToIPFS_. Puede leer más sobre las _API Key_ [aquí](https://medium.com/pinata/introducing-scoped-api-keys-48e808623d5d).

Cuando haya creado su clave, un modal mostrará su _API KEY_, _API Secret_ y su JWT. Solo necesitamos el JWT, así que cópielo y péguelo en el valor de la propiedad _pinataJwt_ del archivo de configuración.

Si creó una _Dedicated Gateway_, usted debe pegar la URL de su _Dedicated Gateway_ en la propiedad _pinataGateway_ del archivo de configuración. Si no tiene una _Dedicated Gateway_, debe actualizar esa propiedad para que se vea así:

```json
pinataGateway: null
```

Finalmente, solo necesita establecer la cantidad de artículos en su colección NFT en la propiedad `number` y el precio en SOL en la propiedad `price`.

Eso es todo lo que necesitas. Ahora, hay mucho más que hacer, pero quiero señalar algo que muchos proyectos probablemente quieran hacer, y eso es ocultar los activos de NFT hasta después de una fecha de revelación. Esto es posible con Metaplex y CandyMachine con configuraciones ocultas. Puedes leer sobre esto  [aqui](https://docs.metaplex.com/candy-machine-v2/configuration#hidden-settings). No haremos eso en este tutorial. El proyecto NFT en este tutorial consiste en apostillar una NFT con revelación inmediata.

Lo último que querrá cambiar en el archivo de configuración es la propiedad `solTreasuryAccount`. Esto probablemente debería apuntar a la dirección de su criptocartera en la red `devnet`, pero puede ser la dirección de cualquier criptocartera de Solana. Para obtener la dirección de sus criptocartera en la red `devnet`, puede ejecutar esto en la línea de comandos:

```bash
solana address
```

Ya estamos listo para cargar algunos activos y crear nuestra colección de NFT.

## Cargando activos a Pinata y Solana

Hemos terminado todo el trabajo de preparación. Es hora de subir los activos. Afortunadamente esto es realmente simple.

En la raíz del directorio del proyecto, ejecute este comando en la línea de comandos:

```shell
ts-node $candymachine upload -e devnet -k ~/.config/solana/devnet.json -cp config.json -c nft-project ./assets
```

```shell
# Output is something like this:
wallet public key: 4aDSG82CdgMwt81z7AwnLnDRZyp6MjvZMUVpT82HZRU9
(node:12028) ExperimentalWarning: buffer.Blob is an experimental feature. This feature could change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
Beginning the upload for 3 (img+json) pairs
started at: 1652029177126
initializing candy machine
Candy machine address:  ENvMsi3pbpsHYbPRg3fKi6hrr8dGjFWNDTybXFGAhG2b
Collection metadata address:  6fqwQEJGQGyGpovV6HmYoF5aB7RscoPCR8BmEjh8X4gG
Collection metadata authority:  4aDSG82CdgMwt81z7AwnLnDRZyp6MjvZMUVpT82HZRU9
Collection master edition address:  5xMAgL4HpjmwxMkJLsoyekQEGTbZCae1AW6NfTGpuKUZ
Collection mint address:  Djp7ZCX2q2mJqmxCv1szirsxsA9N7YW77tEoRdASpp92
Collection PDA address:  98NgHVcz9mV2AdZJCraTR2NHAC8BCvvbtj4ET8gBCijS
Collection authority record address:  zkqyaNFVQsmsFyXVLYJ1Gt6s8jNHcEn6EHkDtehfBu3
Collection:  {
  collectionMetadata: '6fqwQEJGQGyGpovV6HmYoF5aB7RscoPCR8BmEjh8X4gG',
  collectionPDA: '98NgHVcz9mV2AdZJCraTR2NHAC8BCvvbtj4ET8gBCijS',
  txId: '3GkHsk7UANvX3aJugj5fs3LEWi8gvb5uFgUkot6rGTRDS5utXRL7tkKE5JVLnHm2EiHw75VfzFQz3bRDf3P3xbk'
}
initialized config for a candy machine with publickey: ENvMsi3pbpsHYbPRg3fKi6hrr8dGjFWNDTybXFGAhG2b
[0] out of [3] items have been uploaded
Starting upload for [3] items, format {"mediaExt":".png","index":"0"}
Progress: [░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] 0% | 0/3uploaded image:  hs
waiting
uploaded image:  https://ipfs.io/ipfs/QmcPEs45xLiUV4Wq8e8femHetEFcS6uvDKSn5rq6S3
waiting
waiting
waiting
uploaded image:  https://ipfs.io/ipfs/QmQEPmMzbSq4JZDSqtTgTDC9M7zrNvjRkaEej3UZga
waiting
uploaded manifest:  https://ipfs.io/ipfs/QmPSBJv34txUiuwBXrBXNErQuZTXu6AvjHLsm7D
Progress: [█████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░] 33% | 1/3uploaded manifest8
Progress: [███████████████████████████░░░░░░░░░░░░░] 66% | 2/3waiting
uploaded manifest:  https://ipfs.io/ipfs/QmQSCDDskNTV9nFE1ysHJTedkup4jJ3Vzs4pbdJ
Progress: [████████████████████████████████████████] 100% | 3/3
Writing all indices in 1 transactions...
Progress: [████████████████████████████████████████] 100% | 1/1
Done. Successful = true.
ended at: 2022-05-08T17:00:17.542Z. time taken: 00:00:40
```

Este comando tomará su archivo de configuración y lo analizará para que Metaplex sepa cómo cargar sus archivos y cómo obtener la información del NFT apostillado en Solana. Verá en su línea de comando cada carga de los metadatos de su carpeta de activos y las imágenes de su carpeta de activos. Dependiendo de la cantidad de archivos que cargue, este proceso puede tardar unos minutos. Así que rompa una cerveza y espere.

Cuando termine el proceso, deberá hacer una cosa más. Deberá verificar la carga. Esto le ayuda a saber si todo está listo y si sus NFT se pueden acuñar. Solo necesitas ejecutar este comando:

```bash
ts-node $candymachine verify_upload -e devnet -k ~/.config/solana/devnet.json -c nft-project

# Output is something like this:
wallet public key: "YOUR_DEVNET_WALLET_ADDRESS"
(node:118910) ExperimentalWarning: buffer.Blob is an experimental feature. This feature could change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
Key size 3
Looking at key  0
Looking at key  1
Looking at key  2
uploaded (3) out of (3)
ready to deploy!
```

Si todo va bien, debería ver un mensaje que dice `ready to deploy!`. Esto significa que su proyecto está listo para funcionar. Si desea confirmar las cosas puede encontrar la carpeta `.cache` en su directorio de trabajo. Ábralo y verá un archivo JSON que contiene la información de cada activo cargado. El archivo se deber parecer a la siguiente estructura de datos:

```json
{
  "program":{
    "uuid":"ENvMsi",
    "candyMachine":"ENvMsi3pbpsHYbPRg3fKi6hrr8dGjFWNDTybXFGAhG2b","collection":"6fqwQEJGQGyGpovV6HmYoF5aB7RscoPCR8BmEjh8X4gG"
    },
  "items":{
    "0":{
      "link":"https://ipfs.io/ipfs/QmQSCDDskNTV9nFE1ysHJTedkup4jJ3Vzs4pbdrPExGHSJ",
      "imageLink":"https://ipfs.io/ipfs/QmQEPmMzbSq4JZDSqtTgTDC9M7zrNvjRkaEej3UZgDjsaa",
      "name":"Image 0",
      "onChain":true,
      "verifyRun":true
      },
    "1":{
      "link":"https://ipfs.io/ipfs/QmeinbfhRtbkegUf5c3xrYrUZ4TpN3nSZCuvqQNGTEN1r8",
      "imageLink":"https://ipfs.io/ipfs/QmXKXd9bpH4rasEB4i3HLCoHbW76yYyxcmwvHpadgmeRZs",
      "name":"Image 1",
      "onChain":true,
      "verifyRun":true
      },
    "2":{
      "link":"https://ipfs.io/ipfs/QmPSBJv34txUiuwBXrBXNErQuZTXu6AvjHLsm7U5cFRA6D",
      "imageLink":"https://ipfs.io/ipfs/QmcPEs45xLiUV4Wq8e8femHetEFcS6uvDKSn5rq6SCrv63",
      "name":"Image 2",
      "onChain":true,
      "verifyRun":true
      }
  },
  "env":"devnet",
  "cacheName":"nft-project"
}
```
La propiedad `program.candyMachine` la dirección de su programa que puede buscar en el explorador de la blockchain de Solana, que encontrará [aquí](https://explorer.solana.com/). Solo asegúrese de configurar su rede en `devnet`.

Perfecto, ahora puede empezar a acuñar sus NFT. Pero, ¿cómo? Probablemente desees construir un sitio web para permitir la acuñación de NFT. Afortunadamente, el código base de Metaplex nos tiene cubiertos. 

## Construyendo un sitio web para acuñar NFT
¿Recuerdas que clonamos el repositorio completo de Metaplex? Lo clonamos en la carpeta `nft-project`. Entonces, desde su línea de comandos, cambiamos a nuestro directorio de trabajo y al proyecto metaplex, directamente a la aplicación React de muestra: 

```bash
cd ~/metaplex/js/packages/candy-machine-ui
```

Deberá instalar las dependencias de esta manera:
```bash
yarn install
```
 
 Luegon, abra el proyecto en su editor de preferencia. Verá un archivo `.env` que contiene la configuración de su proyecto. Deberías actualizarlo para que se vea así:

 ```text
  REACT_APP_CANDY_MACHINE_PUBLIC_KEY=YOUR_PUBLIC_KEY
  REACT_APP_CANDY_MACHINE_ENV=devnet
  REACT_APP_SOLANA_RPC_URL=https://api.devnet.solana.com
  ```

¿Recuerdas que usamos el `ID` de la Candy machine para buscar nuestro proyecto en Solana Explorer? Vamos a pegar ese mismo ID donde dice `YOUR_PUBLIC_KEY`.

Ahora, puede ejecutar la aplicación de con:

```bash
yarn start
```

Cuando se cargue la aplicación, deberías ver:
![CandiMachine](candymachine.png "Figura 1. User Interface")

Podrá elegir una criptocartera para conectarse. Independientemente de la criptocartera que selecciones, deberá asegurarse de que algo de SOL de desarrollo. ¿Recuerdas cuando recibimos algunos SOL desde `devnet`? También podemos hacerlo con otra dirección. Conecte su billetera, asegúrese de estar en `devnet`, y luego copie la dirección de la criptocartera que desea usar. Desde la línea de comandos, escriba:

```bash
solana airdrop 2 YOUR_PUBLIC_KEY --url devnet
```

Una vez que esto esté completo, debería tener SOL en su criptocartera basada en navegador y ahora puede acuñar uno de sus nuevos NFT. Para hacerlo, simplemente haga clic en el botón de acuñar (Mint):
![CandiMachine](candymachine1.png "Figura 2. Botón para acuñar un NFT")

Deberás confirmar la transacción. Cuando lo haga, el proceso de acuñación solo debería tomar unos segundos. Una vez que esté completo, su nuevo NFT debería aparecer en la colección de NFTs de su criptocartera.

La imagen que ve de su NFT se está cargando desde Pinata. Dependiendo de si proporcionó una URL de puerta de enlace dedicada en su archivo de configuración, el NFT ser carga a través de su puerta de enlace personalizada o una puerta de enlace IPFS pública. Nota: si proporcionó una URL de puerta de enlace dedicada, el NFT será cargado a través de su puerta de enlace personalizada, y si no, el NFT será cargado a través de una puerta de enlace IPFS pública. Puede ver esto en el siguiente ejemplo usando Phantom Wallet. Los dos NFT que están atascados en la carga están usando una puerta de enlace IPFS pública. Los dos que se cargan casi instantáneamente en la carga están usando una puerta de enlace personalizada.

![Wallet](wallet.png "Figura 3. NFTs apostillados en la Wallet personalizada")

Al ver su NFT en los mercados de Solana NFT, los activos también se cargarán a través de la puerta de enlace de IPFS. Esto permite que las personas puedan ver el contenido de la forma en que fue diseñado para ser experimentado. 

## Conclusiones

Los beneficios de usar IPFS para el almacenamiento de activos NFT están bien documentados. IPFS ofrece una recuperación rápida (especialmente cuando se usa una puerta de enlace dedicada de Pinata), IPFS ofrece la direccionalidad de contenido e IPFS es portátil. La propiedad del NFT puede transferirse tanto en el sentido simbólico como el en sentido dígital. 

Sin embargo, no siempre ha sido fácil usar IPFS con proyectos de Solana NFT. Con suerte este tutorial ayudará a cambiaro eso.

## Patrocinio 
₿itcoin: [bc1qrcecrz47ywrcnyuqknzgzzz2t3lwawyjnl4t7f](https://www.exodus.com/)

Solana: [Ft8A8t3UyGZHjWNvtgruADnUgrij3uaFe7pLj9QNG44N](https://phantom.app/)

Ethereum: [0x886ce8Cc54cd0964E6939c5290242b1135D10C7f](https://metamask.io/)

Paypal: [@asanchezyali](https://paypal.me/asanchezyali?country.x=CO&locale.x=es_XC)
## Imágenes

  - [Unplash](https://unsplash.com/) - [NTF inscription on cubes against the background of dollars and microcircuits](https://unsplash.com/photos/yscrM1AOEKI).
  - [Unplash](https://unsplash.com/) - [Foto 1](https://unsplash.com/es/fotos/W6l35A_rxxU), [Foto 2](https://unsplash.com/es/fotos/ir5gC4hlqT0) y [Foto 3](https://unsplash.com/es/fotos/0XkLAIrknco) de [Michael Dziedzic](https://unsplash.com/es/@lazycreekimages)
## Referencias

1. [Justin Hunter. How to create a Solana NFT with IPFS](https://medium.com/pinata/how-to-create-a-solana-nft-with-ipfs-59d87afbe206)
2. [Metaplex Docs](https://docs.metaplex.com/)
3. [Web3.js](https://github.com/ChainSafe/web3.js)
4. [Metaboss](https://metaboss.rs/update.html)