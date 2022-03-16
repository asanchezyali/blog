# Agricultura de precisión


En esta ocasión vamos a aprender cómo monitorizar una planta empleando un bot de telegram y una raspberry pi 3 model b. Este artículo que aquí se desarrolla, busca cubrir la monitorización remota de una plata, asi como la instalación de actuadores que puedan interactuar con la misma. Todo esto controlado desde un _bot_ desarrollado para la plataforma _Telegram Messenger_.

Por lo tanto, el principal objetivo es desarrollar un _bot_ que sea capaz de comunicarse con un servidor, en nuestro caso con una placa _Raspberry Pi_, y que sea capaz de recibir información de sensores conectados a la placa y enviar órdenes a los actuadores que interactuarán con la planta supervisada.

Asimismo, se desarrollará un sistema de gestión de usuarios para permitir al administrador del _bot_ que solo hagan uso del mismo aquellos usuarios legítimos y con los permisos que les hayan concedido. Por lo tanto, será necesario desarrollar esta capa de seguridad. 

Para el desarrollo de este proyecto, será necesario dominar diferentes tecnologías entre las que, inicialmente, se encuentran:

1. Telegram Messenger: habrá que estudiar cómo se realizan _bots_ en esta plataforma, y averiguar cómo se ponen en funcionamiento y a disposición de los usuarios.
2. Raspberry Pi: será necesario familiarizarse con el entorno _Raspberry Pi_ para poder llegar a usar esta placa para los fines que se ha descrito. 

## Requisitos del bot

Los objetivos generales a cubrir con el _bot_ serán los siguientes:

* Comprobar la temperatura de la planta.
* Poder ventilar la planta.
* Comprobar la humedad ambiental.
* Poder regar la planta.
* Controlar el acceso al _bot_ así como los permisos que se asignan a los distintos usuarios.
* Poder visualizar la planta de manera remota.

No obstante, para planificar el correcto desarrollo del _bot_, hay que pensar en los usuarios que van a utilizarlo. Para ello, se va a hacer un pequeño modelado de usuarios y se verá qué característica tendrán los mismos. 

Se verá también qué requisitos serán necesarios cumplir para que el _bot_ cubra el alcance del proyecto y permita interactuar con la planta, tal y como se había planificado. 

Diferenciaremos entre dos tipos de usuarios: los administradores del _bot_ y los usuarios autorizados. Los demás usuarios (usuarios no autorizados) no se tendrán en cuenta, ya que no podrán interactuar con el _bot_.

Los usuarios autorizados podrán interactuar con la planta en función de los permisos que se les hayan asignado.

Los permisos, los podrán asignar los usuarios administradores desde el propio _bot_, e irán desde simples consultas del estado de la planta, hasta tener el control total de la misma. 

Por lo tanto se ha definido:

* Usuarios no autorizados: no pueden interactuar con el _bot_.
* Usuarios autorizados: pueden actuar con el _bot_ en función de sus permisos.
* Administradores: son usuarios autorizados con todos los permisos y pueden gestionar a los usuarios.

Ahora se pasa a ver qué tipo de requisitos necesita cubrir el _bot_ tanto en la parte del cuidado de la planta como en la gestión de usuarios que se ha comentado.

Si queremos conseguir que los usuarios sean capaces de recibir toda la información de los sensores conectados a la Raspberry Pi, y poder actuar con la planta mediante los actuadores, tendresmos que cubrir una serie de requisitos funcionales básicos.

Los requisitos funcionales del _bot_ se detallarán a continuación:

**Requisitos relacionados con los sensores:

* Ver el estado de l planta
* Visualizar la temperatura
* Visualizar la humedad
* Solicitar una fotografía de la planta

**Requisitos relacionados con los actuadores:**

* Encender/apagar la luz
* Encender/apagar la ventilación
* Regar la planta

Y en cuanto a la gestión de usuarios, será necesario gestionar estas funcionalidades:
* Solicitar permisos de uso
* Admitir usuarios que han solicitado permiso
* Restringir usuarios
* Cambiar permisos a usuarios

Ahora, se va a estudiar los perfiles de usuario que se pueden crear, y qué requisitos asignar a cada uno de ellos.

Usuario sin permisos, podrá:
* Solicitar permiso para utilizar el _bot_

Y se definen tres tipos de usuarios con permisos:
Usuario «supervisor», para supervisar la planta, podrá:
* Solicitar más permisos
* Ver estado de la planta
* Visualizar temperatura
* Visualizar humedad ambiental

Usuario «jardinero», además de los anteriores permisos, podrá:
* Solicitar una fotografía de la planta
* Encender/apagar luz
* Encender/apagar ventilación
* Regar la planta

Usuario «administrador», tendrá todos los permisos anteriores, así como los relativos
a la gestión de usuarios. Los propios de gestión de usuarios permitirán:
* Conceder permisos de uso
* Denegar permisos de uso
* Ascender a un usuario a un perfil superior
* Degradar a un usuario a un perfil inferior

Con todo esto, ya se tiene una imagen más clara de todas las acciones que permitir
realizar el sistema. En base a ellas, se desarrollarán tanto las soluciones hardware como
software.

## Tecnologías

Tal y como se ha definido previamente, se emplearán sensores y actuadores conec-
tados directamente a la placa Raspberry Pi que, a su vez, alojará tanto el bot que se
desarrollará en lenguaje Python como la base de datos necesaria para su funcionamiento.
Todas estas tecnologías y las subyacentes se explican en este apartado.
Se comenzará hablando del hardware, con mayor incidencia en Raspberry Pi, y des-
pués se pasará al software, con mención especial para Telegram y la base de datos. 

### Hardware
#### Raspberry Pi
Raspberry Pi es un ordenador de placa reducida de bajo coste, desarrollado en Reino
Unido por la fundación Raspberry Pi, con el objetivo principal de incitar tanto a niños
como a adultos a que aprendan sobre ordenadores y todo lo relacionado con los mismos.

La idea de desarrollar algo así surgió en 2006 cuando Eben Upton, Rob Mullins, Jack
Lang y Alan Mycroft, del laboratorio de informática de la Universidad de Cambridge,
constataron cómo habían cambiado los conocimientos de los niños sobre la informática.
En la década de los 90, surgió mucha afición por la programación entre la juventud, pero
a partir del año 2000 la tendencia fue disminuyendo y esa inquietud se dirigió, principal-
mente, a la programación web, de mucho más alto nivel.

La fundación Raspberry Pi surgió con un objetivo en mente: Desarrollar el uso y
entendimiento de los ordenadores en los niños. Su idea es conseguir ordenadores muy baratos que permitan a los niños usarlos sin miedo, abriendo su mentalidad, y educándolos en la ética del «ábrelo y mira cómo funciona».

En este proyecto se trabajará con una placa Raspberry Pi 3 modelo B. Las característi-
cas de este modelo son las siguientes:

*** Buscar las características

#### Sensores y actuadores

En este apartado, veremos las características de los sensores que se emplearán para
monitorizar la planta.

En primer lugar, se nombran todas las funciones que cubren los sensores:
* Medida de temperatura
* Medida de humedad
* Toma de fotografías

Estas funciones se traducirán en un sensor de temperatura y humedad y una cámara
web.

Para el sensor de temperatura y humedad ambiental, se va a contar con el sensor
DHT11. Se trata de un sensor digital de alta fiabilidad y estabilidad, por su señal digital
calibrada. Se ha adquirido un sensor con placa PCB, donde va insertado para facilitar su
uso.


**Transmisión de datos del sensor DHT11**
Aunque se ha dicho que el sensor es digital, en realidad esto no es del todo correcto,
ya que realmente el sensor es analógico, pero internamente se realiza la conversión a se-
ñal digital, y la devuelve en una trama como la que se muestra a continuación.



Como se puede ver, el primer grupo de 8 bits es la parte entera de la humedad, y el
segundo la parte decimal. Lo mismo para la temperatura, donde la parte entera sería el
tercer grupo, y la parte decimal el cuarto. Por último se encuentran los bits de paridad
para confirmar que no hay datos corruptos.

Actualmente existen librerías que recogen estas tramas y devuelven los valores en de-
cimal. Una de estas librerías es `Adafruit`.


Para poder utilizar la librería `Adafruit`, se deberá instalar desde su repositorio en lí-
nea y, una vez hecho, ya se podrá solicitar los datos al sensor, y así recibirlos en consola
*** Agregar foto


**Cámara web**
Para la toma de fotografías se va a emplear una cámara web. Se consulta en Internet
el listado de cámaras compatibles con Raspberry Pi para comprobar si se tiene alguna
de las listadas o, en su defecto, buscar una compatible para comprar

**Actuadores**
Para actuar con la planta, se contará con una serie de componentes para:

* Ventilación del invernadero
* Riego de la planta
* Iluminación del invernadero

**Ventilador**
Para llevar a cabo la ventilación del invernadero, se va a contar con un pequeño ven-
tilador diseñado para refrigerar ordenadores portátiles que, debido a su tamaño, es suficiente para el cometido, y que tan solo requiere un potencial de 5 voltios para su alimen-
tación.


## Imágenes

  [Unplash](https://unsplash.com) - [Sunset over Limuru tea farm](https://unsplash.com/photos/PvwdlXqo85k).

## Referencias

1. [Julius Berner. 2021. The Modern Mathematics of deep learning.](https://deepai.org/publication/the-modern-mathematics-of-deep-learning)
2. [Yaser Abu-Mostafa Data. 2012 - 2015. Learning From Data.](https://work.caltech.edu/telecourse)


