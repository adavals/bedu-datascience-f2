# RESULTADOS
A continuación aparecen una serie de objetivos que deberás cumplir, es un ejemplo real de aplicación y tiene que ver con datos referentes a equipos de la liga española
de fútbol (recuerda que los datos provienen siempre de diversas naturalezas), en este caso se cuenta con muchos datos que se pueden aprovechar, explotarlos y generar análisis interesantes que se pueden aplicar a otras áreas. Siendo así damos paso a las instrucciones:

## 1. Del siguiente enlace, descarga los datos de soccer de la temporada 2019/2020 de la primera división de la liga española: 

https://www.football-data.co.uk/spainm.php

[-> Ver archivo CSV de datos](https://github.com/adavals/bedu-datascience-f2/blob/main/s1/postwork/dat/SP1.csv)

## 2. Importa los datos a R como un Dataframe. NOTA: No olvides cambiar tu dirección de trabajo a la ruta donde descargaste tu archivo
```
setwd("~/BeduDataScience/Sesion_01_Postwork")
SP1 <- read.csv("SP1.csv")
View(SP1)
```
[-> Ver descripción de datos](https://github.com/adavals/bedu-datascience-f2/blob/main/s1/postwork/dat/notes.txt)

![csv cargado](https://github.com/adavals/bedu-datascience-f2/blob/main/s1/postwork/img/loaded_csv.png)

## 3. Del dataframe que resulta de importar los datos a `R`, extrae las columnas que contienen los números de goles anotados por los equipos que jugaron en casa (FTHG) y los goles anotados por los equipos que jugaron como visitante (FTAG); guárdalos en vectores separados
```
vector.FTHG <- SP1$FTHG
vector.FTAG <- SP1$FTAG
```
![vectores](https://github.com/adavals/bedu-datascience-f2/blob/main/s1/postwork/img/vectors_FTAG_FTHG.png)
## 4. Consulta cómo funciona la función `table` en `R`. Para ello, puedes ingresar los comandos `help("table")` o `?table` para leer la documentación.
```
help("table")
```

## 5. Responde a las siguientes preguntas:
```
table(vector.FTHG,vector.FTAG, dnn=list("FTHG","FTAG"))
```
![tabla](https://github.com/adavals/bedu-datascience-f2/blob/main/s1/postwork/img/result_table.png)

### a) ¿Cuántos goles tuvo el partido con mayor empate?
     R. 4 goles  
###  b) ¿En cuántos partidos ambos equipos empataron 0 a 0?
     R. 33 partidos
###  c) ¿En cuántos partidos el equipo local (HG) tuvo la mayor goleada sin dejar que el equipo visitante (AG) metiera un solo gol?
     R. 1 partido   (local:6 - visitante: 0)

### [Ver código fuente R][def]


[def]: https://github.com/adavals/bedu-datascience-f2/blob/main/s1/postwork/src/Sesion_01_Postwork.R