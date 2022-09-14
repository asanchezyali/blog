# Fundamentos de la tecnología Blockchain


## Introducción

Una _blockchain_ es una forma de almacenar datos a través de una red de servidores (nodos) que interactúan mediante un protocolo de intercambio _peer-to-peer_ y que hacen uso de la criptografía para garantizar la integridad de los datos de forma segura, en principio sin la presencia de una autoridad central reguladora. una blockchain es más que un simple algoritmo, es una tecnología que facilita la descentralización y el acceso a los datos a cada uno de los participantes de la red, estableciendo un nuevo paradigma en la forma de como relacionarse con la información, _no confíes, verifica_. La revolución de este paradigma no se deriva de ¿Qué es una cadena de bloques? sino de como es usada e implementada. Solo el TCP-IP (_Transmission Control Protocol and Internet Protocol_) inventado en los setentas en DARPA, habilitó el intercambio descentralizado de la información, (es decir, la internet), pero las blockchain habilitaron el control descentralizado del intercambio de la información. En efecto, la innovación con las _blockchains_ no se deriva del desarrollo de una nueva tecnología, pero si en la forma como se  utilizan tecnologías que ya existían desde antes (métodos de _hasheo_, encriptación asimétrica y la arquitectura de redes _peer-to-peer_) para el intercambio de información.

Las blockchains habilitaron la creación de un *libro contable* y un mecanismo para compartir la información a través de la red independiente de las partes (nodos) que están conectados via la infraestructura del internet. Cada nodo tiene exactamente una copia del libro contable en cada momento, garantizando así la creación de registros de transacciones permanentes con un sello de tiempo que es consisten en todos los nodos subyacentes de la cadena de bloques. Además, para que un registro sea alterado, la mayoría de los participantes de la red de la blockchain deberán simultáneamente de acuerdo para cambiar la información, y hay que sortear varias salvaguardas adicionales: una vez que un nodo almacena información en la base de datos de la blokchain, es casi imposible eliminarla.

En este artículo vamos a introducir la terminología relevante y la funciones básicas de una blockchain de las que predispone para realizar sus operaciones, como ejemplo vamos a implementar una pequeña blockchain en Python.

## Terminología
Vamos a comenzar por establecer la diferencia entre una blockchain y un DLT (_Distributed Ledger Technology_).

Una blockchain es una estructura de datos con la que se almacena de la historia de las transacciones de forma permanente, mientras un DLT, es una estructura de datos que reside a través de múltiples dispositivos de computo y que en general están dispersos a través de diferentes localidades o regiones. 

Por lo tanto, las blockchains es un subconjunto de DLTs y en su mayoría las blockchains son conocidas como la tecnología detrás de Bitcoin, Ethereum y otras criptomonedas. El termino blockchain es el algunas ocasiones usado para referirse a las transacciones y algunos otro tipo de datos que son resumidos en bloques y adjuntados a la blockchain cuando ya han sido bloques verificados.
