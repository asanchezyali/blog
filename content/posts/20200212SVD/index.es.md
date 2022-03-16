---
weight: 3
title: "Descomposición matricial por valores singulares (SVD)"
date: 2022-02-10 23:31:34 
draft: false
excerpt: Una breve introducción al problema del aprendizaje a partir de los datos.
timeToRead: 4
authors:
  - Alejandro Sánchez Yalí
description: "¿Cómo aprendemos los humanos? En principio la mayoría del conocimiento humano proviene de nuestra experiencia con los objetos, es decir, aprendemos de los datos que obtenemos acerca de ellos y no a partir de algún tipo de definición matemática."
resources:
- name: "featured-image"
  src: "featured-image.webp"
tags:
  - Machine Learning
  - Tareas de aprendizaje
  - Regresión
  - Clasificación

categories:
  - Inteligencia Artificial
keywords:
  - Teoría del aprendizaje
  - Tareas de aprendizaje
  - Regresión
  - Clasificación

lightgallery: true
---
En esta ocasión vamos a introducir la descomposición por valores singulares (SVD por sus siglas en inglés) y cómo aplicar la SVD mediante ejemplos prácticos desarrollados en Python, Rust y C++. Es importante entender la SVD porque es el fundamento otras técnicas de aprendizaje mecánico, como lo es los métodos de clasificación, la descomposición dinámica (DMD) y la descomposición ortogonal propia (POD).

La alta dimensionalidad es un reto común en el procesamiento de datos que proviene de sistemas complejos. Por ejemplo con datos que provienes de fuentes de audio, video o imagenes. Los datos también puede ser generados por sistemas físicos, como lo es el registros de interacciones neuronales de un cerebro, o la registros de velocidad de una simulación del movimiento de un fluido o  experimento.Es natural que en la mayoría de los sistemas, los datos exhiban patrones dominantes, que pueden ser caracterizados por atractores o variedades de dimensionalidad baja. 

La SVD provee una forma sistemática para determinar una aproximación de baja dimensionalidad a un conjunto de datos de alta dimensionalidad en términos de los patrones dominantes. Esta técnica «direcciona los datos» en descubrir esos patrones propiamente de los datos, si recurrir al conocimiento del experto de los datos o la intuición. La SVD es numéricamente estable y provee una representación herarquica de los datos en términos de un nuevo sistema de coordenadas definido por las correlaciones dominantes en los datos. Además, la SVD existe para cualquier matriz, lo que la diferencias de la descomposición por valores propios. 

La SVD tiene aplicaciones muy importantes que van más allá de la reducción de dimensionalidad de datos de alta dimensionalidad. Es usada para calcular las psudo-inversa de matrices no cuadradas, 
proporcionando soluciones a sisteamas de ecuaciones matriciales infradeterminadas o sobredeterminadas, $\pmb{A}x=b$. La SVD también se emplea para la reducción de ruido en conjunto de datos. La SVD también es igual de importante para caracterizar la geometria de entrada y salida de una transformación lineal entre espacios vectoriales. (Agregar referencias).

## Definición de la SVD
En general, el objetivo es analizar un conjunto de datos con la estructura $X\in \mathcal{C}^{n\times m}$:
\begin{equation}
X=\begin{pmatrix}
| & | &  & | \\\
x\_1 & x\_2 & \cdots & x\_m \\\
| & | &  & | \\\
\end{pmatrix}.
\end{equation}

La columnas $x\_k\in \mathcal{C}^{n}$ puede ser medidas de una simulación o resultados de un experimento. Por ejemplo, las columnas puede representar imagenes que han sido reorganizadas en vectores columnas en donde cada entrada es un pixel en la imagen. El indice $k$ es una etiqueta que indica el registro $k$-ésimo de las medidas. En muchas ocasiones, $X$ consiste de una serie de datos, de tal forma que $x\_k =x(k\delta t)$. Con frecuencia de la dimensión $n$ es muy grande, en un orden de un millón o billones de grados de libertad. La columna amenudo se denomina _registros_, y $m$ es el número de registros en $X$. Para muchos sistemas $n\gg m$, resultando en una matrix _tall-skinny_, que es opuesta a una matriz _short-fat_ cuando $n\ll m$.

La SVD es una descomposición matricial única que existe para todas las matrices $X\in \mathcal{C}^{n\times m}$:

\begin{equation}
X= U\Sigma V^{*}
\end{equation}

donde $U\in \mathcal{C}^{n\times n}$ y $V\in \mathcal{C}^{m\times m}$ son matrices unitarias con columnas ortonormales, y $\Sigma \in \mathcal{R}^{n\times m}$ es una matriz con entradas reales, no negativas en la diagonal principal y cero en fuera de ella. Aquí $^\*$ denota la transposición de matrices complejas.

Cuando $n\geq m$, la matriz $\Sigma$ tiene al menos $m$ elementos no nulos sobre la diagonal principal, así que la matriz $\Sigma$ se puede escribir como $\Sigma = \begin{bmatrix} \hat{\Sigma} \\\ 0 \end{bmatrix}$. Por lo tanto, una representación exacta de $X$ usando la descomposición económica de SVD:

\begin{equation}
X=U\Sigma V^{\*} = \begin{bmatrix} \hat{U} & \hat{U}^{\perp}\end{bmatrix}\begin{bmatrix}\hat{\Sigma} \\\ 0 \end{bmatrix} V^{\*} = \hat{U}\hat{\Sigma} V^{\*}.
\end{equation}

La decomposición completa SVD y la decomposición económica SVD se ilustran en la figura (xxx). Las columnas de $\hat{U}^{\perp}$ generan el espacio vectorial que es complementario y ortogonal al espacio generado por $\hat{U}$. Las columnas de $U$ se denominan _vectores singulares a izquierda_ de $X$ y las columnas de $V$ son los _vectores singulares a derecha_. Los elementos de la diagonal de $\hat{Sigma}\in \mathcal{C}^{m\times m}$ se denominan valores propios y son ordenados de de mayor a menor. El rango de $X$ es igual al número de valores singulares no nulos.

## Calculando la descomposición SVD

La descomposición SVD es la piedra angular de la ciencia computacional y la ingeniería. Su implementación númerica es importante y matemáticamente esclarecedora. Dicho esto, la mayoría de las implementaciones númericas están desarrolladas e implementadas con una interfaz simple en la mayoría de los lenguajes de programación modernos, lo que nos permite abstraer los detalles computacionales que hay detrás de la descomposición SVD. Para la mayoría de los propositos, nosotros vamos a asumir que SVD proviene ya de un esfuerzo colectivo mayor y que por lo tanto ya viene garantizada la existencia de eficiencia y estabilidad de los algoritmos que vamos a emplear. A continuación, vamos a ilustrar como usar la descomposición SVD en varios lenguajes de programación.

### SVD con Python

```python
import numpy as np
# Create radom data matrix
X = np.random.rand(5, 3)
# full SVD
U, S, V = np.linalg.svd(X, full_matrices=True)
# economy SVD
U_hat, S_hat, V_hat = np.linalg.svd(X, full_matrices=False)
```

### Otros lenguajes
La descomposición SVD también está disponible en otros lenguajes, como Fortran, C++, Rust, R, Julia. En efecto, la mayoría de las implementaciones de SVD se basan en LAPACK en Fortran. La rutina de SVD se designa como DGESVD en LAPACK, y esto está envuelto en las librerías **Armadillo** y **Eigen** de C++.






## Referencias

1. [Julius Berner. 2021. The Modern Mathematics of deep learning.](https://deepai.org/publication/the-modern-mathematics-of-deep-learning)
2. [Yaser Abu-Mostafa Data. 2012 - 2015. Learning From Data.](https://work.caltech.edu/telecourse)

