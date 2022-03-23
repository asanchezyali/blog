---
weight: 1
title: "¿Cómo crear un NFT en Solana con IPFS?"
date: 2022-03-23T08:19:27-05:00
draft: false
excerpt: Programando Dapps sobre Solana
hero: /images/ml-01.jpg
timeToRead: 4
authors:
  - Alejandro Sánchez Yalí
description: "Una blockchain es una libro de registros de bloques de información que son almacenados secuencialmente y enlazados por métodos criptográficos a través de una red de computadores. Es más que un simple algoritmo, blockchain es una tecnología que facilita la intermediación descentralizada de datos entre los participantes"
resources:
- name: "featured-image"
  src: "featured-image.webp"
tags:
  - Sistemas distribuidos

categories:
  - Blockchain
keywords:
  - Solana
  - Anchor
  - Phantom Wallet
  - Dapps

lightgallery: true
---

Los NFTs son mucho más que images generadas aleatoriamente, esto promete ser la revolución en los títulos de propiedad digital en la web tal y como la conocemos. Si quieres aprender más acerca de esto, te recomiendo leer el articulo de Nick Szabo, [_Secure Property Titles with Owner Authority_](https://nakamotoinstitute.org/secure-property-titles/), allí encontrarás las primeras ideas acerca de todo este asunto de los NFTs.

A continuación vamos a ver cómo crear una colección de NFTs en Solana usando Pinata e IPFS. Este es un tutorial especialmente interesante porque Solana ha estado estrechamente vinculado Arweave, pero muchos proyectos prefieren IPFS por su rápido acceso al contenido y su fiabilidad. Metaplex, es un proyecto construido para hacer más fácil la creación de proyectos NFT en Solana y tiene soporte para IPFS, y esto incluye la capacidad para usar Pinata para almacenar contenido y servir este contenido a través de una puerta de enlace IPFS dedicada. 

## Configuración del ambiente de trabajo

Para empezar, asegúrate de registrarte en [Pinata](https://www.pinata.cloud/). Usted puede hacer pruebas con una cuenta gratuita, pero para el lanzamiento de NFTs en la red principal, debes considerar el plan professional con una puerta de enlace IPFS dedicada. 

Una vez que te hayas inscrito en una cuenta, sólo tienes que asegurarte de que tienes instalados los siguientes elementos (cada uno de ellos está vinculado a las instrucciones de instalación en caso de que tengas que instalarlos):

* [Node.js](https://nodejs.org/en/download/) version 16.13.0 o la más reciente.
* [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) versión 2.32.0 o la más reciente.
* [Yarn](https://classic.yarnpkg.com/lang/en/docs/install/#mac-stable) versión 1.22.17 o la más reciente.
* [ts-node](https://www.npmjs.com/package/ts-node#installation) versión 10.4.0 o la más reciente.
* [Solana CLI](https://docs.solana.com/cli/install-solana-cli-tools) version 1.8.16 o la más reciente.

Por si sirve de algo, seguiremos gran parte de las instrucciones de la página web de [Metaplex](https://docs.metaplex.com/candy-machine-v2/getting-started) con algunas modificaciones que nos permitan subir contenidos a IPFS a través de Pinata.

## Preparando los activos

Este tutorial no va a pasar por el proceso de generar los activos para su proyecto  de NFTs. Ese es un esfuerzo totalmente separado que tiene que ocurrir antes de que el contrato puede ser desplegado en Solana. Así que, asumiendo que usted tiene el arte creado, vamos a caminar a través de cómo preparar esto para subir a IPFS a través de Metaplex.

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