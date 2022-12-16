# RESULTADOS
# Requisitos 
# - Haber realizado los works y postworks previos 
# - Tener una cuenta en Github o en RStudioCloud 
# Desarrollo 
# Un centro de salud nutricional está interesado en analizar estadísticamente y
# probabilísticamente los patrones de gasto en alimentos saludables y no
# saludables en los hogares mexicanos con base en su nivel socioeconómico, en si
# el hogar tiene recursos financieros extras al ingreso y en si presenta o no
# inseguridad alimentaria. Además, está interesado en un modelo que le permita
# identificar los determinantes socioeconómicos de la inseguridad alimentaria.
# 
# La base de datos es un extracto de la Encuesta Nacional de Salud y Nutrición
# (2012) levantada por el Instituto Nacional de Salud Pública en México. La
# mayoría de las personas afirman que los hogares con menor nivel socioeconómico
# tienden a gastar más en productos no saludables que las personas con mayores
# niveles socioeconómicos y que esto, entre otros determinantes, lleva a que un
# hogar presente cierta inseguridad alimentaria.
#
# La base de datos contiene las siguientes variables:
#
# nse5f (Nivel socioeconómico del hogar): 1 "Bajo", 2 "Medio bajo", 3 "Medio", 4
# "Medio alto", 5 "Alto" 
# area (Zona geográfica): 0 "Zona urbana", 1 "Zona rural"
# numpeho (Número de persona en el hogar) 
# refin (Recursos financieros distintos al ingreso laboral): 0 "no", 1 "sí" 
# edadjef (Edad del jefe/a de familia)
# sexojef (Sexo del jefe/a de familia): 0 "Hombre", 1 "Mujer" 
# añosedu (Años de educación del jefe de familia) 
# ln_als (Logaritmo natural del gasto en alimentos saludables) 
# ln_alns (Logaritmo natural del gasto en alimentos no saludables) 
# IA (Inseguridad alimentaria en el hogar): 0 "No presenta IA", 1 "Presenta IA"
#
# df<-read.csv("https://raw.githubusercontent.com/beduExpert/Programacion-R-Santander-2022/main/Sesion-08/Postwork/inseguridad_alimentaria_bedu.csv")

library(DescTools)
library(ggplot2)
library(dplyr)
library(moments)

#
# I. Plantea el problema del caso 

# El objetivo de este trabajo es saber si es posible identificar los determinantes
# socioeconómicos de la inseguridad alimentaria.

# Con base en la información que maneja el centro nutricional las siguientes
# interrogantes guían este trabajo:
#   
# 1. ¿Cuáles son los patrones de gasto en alimentos saludables y no saludables en 
# los hogares mexicanos considerando su nivel socioeconómico, si cuenta con recursos
# financieros extra y si presenta inseguridad alimentaria?
# 2. ¿Los hogares con menor nivel socioeconómico tienden a gastar más en productos 
#  no saludables que los hogares con mayores niveles socioeconómicos?  
# 3. ¿El que los hogares con menor nivel socioeconómico gasten más en productos
#  no saludables los lleva a que presente inseguridad alimentaria?
# 4. ¿Es posible encontrar un modelo que permita identificar los determinantes 
#   socioeconómicos de la inseguridad alimentaria?


# II. Realiza un análisis descriptivo de la información 

df.raw <-read.csv("https://raw.githubusercontent.com/beduExpert/Programacion-R-Santander-2022/main/Sesion-08/Postwork/inseguridad_alimentaria_bedu.csv")
dim(df.raw)   
# 40809 observaciones y 10 variables

# Visualización de datos
View(df.raw)

# Conocer qué información no está disponible
apply(X = is.na(df.raw), MARGIN = 2, FUN = sum)
apply(X = is.na(df.raw), MARGIN = 2, FUN = mean)

# Porcentajes de datos faltantes:
# ln_alns   42%
# ln_als    19%
# edadjef   12%
# sexojef   12%

# Examinar la información de Inseguridad alimentaria que no estaría disponible
df.NA.ln_alns <-df.raw[(is.na(df.raw$ln_alns)),]
View(df.NA.ln_alns)
df.NA.ln_alns$IA <- factor(df.NA.ln_alns$IA, labels = c("No presenta IA", "Presenta IA"))
summary(df.NA.ln_alns$IA)

df.NA.ln_als <-df.raw[(is.na(df.raw$ln_als)),]
df.NA.ln_als$IA <- factor(df.NA.ln_als$IA, labels = c("No presenta IA", "Presenta IA"))
summary(df.NA.ln_als$IA)

# Imputación de datos vs quitar incompletos:
# Decidimos quitar incompletos debido a que requerimos más tiempo para documentarnos
# sobre las diferentes técnicas y la información sobre las razones por las que no 
# están disponibles estos datos para darles un tratamento adecuado.

# Limpieza: se eliminan observaciones incompletas
df <- df.raw[complete.cases(df.raw),]
dim(df)   
# 20280 observaciones completas y 10 variables
View(df)

# 1. Tipos de variables
# El conjunto de datos contiene 10 variables:
# nse5f es cualitativa ordinal
# area, refin, sexoje, IA son cualitativas nominales
# numpeho, edadjef, añosedu son cuantitativas discreta
# ln_als, ln_alns son cuantitativas continuas

# transformación de variable cualitativa con factor
df$nse5f <- factor(df$nse5f, labels = c("Bajo", "Medio bajo", "Medio", "Medio alto", "Alto"))
df$area <- factor(df$area, labels = c("Zona urbana","Zona rural")) 
df$refin <- factor(df$refin, labels = c("no", "sí" ))
df$sexojef <- factor(df$sexojef, labels = c("Hombre","Mujer")) 
df$IA <- factor(df$IA, labels = c("No presenta IA", "Presenta IA"))

# 2. Medidas de tendencia central y posición
summary(df)

# 3. Medidas de dispersión
sd(df$numpeho); sd(df$edadjef); sd(df$añosedu)
sd(df$ln_als); sd(df$ln_alns)

# TO DO: Hacer tabla de Interpretaciones
# Ej. Dado que moda < mediana < media, la distribución está sesgada a la derecha."
# sd() # El precio tiene una dispersión promedio, respecto a la media, de 3989.44
# quantile(diamonds$price, probs = c(0.25, 0.50, 0.75))
# 25% de los diamantes tienen un precio de 950 o menos
# 50% de los diamantes tienen un precio de 2401 o menos
# 75% de los diamantes tienen un precio de 5324.25 o menos

# 4. Formas de distribución
# Sesgo
#s > 0 Sesgo a la derecha
#s = 0 Simétrica
#s < 0 Sesgo a la izquierda

skewness(df$numpeho) 
# 0.9393 - Sesgo a la derecha

skewness(df$edadjef) 
# 0.4853 - Sesgo a la derecha

skewness(df$añosedu) 
# -0.4102 - Sesgo a la izquierda

skewness(df$ln_als)
# -1.1918 - Sesgo a la izquierda

skewness(df$ln_alns)
# 0.2431 - Sesgo a la derecha

# kurtosis
#Leptocúrtica k > 3
#Mesocúrtica k = 3
#Platocúrtica k < 3

kurtosis(df$numpeho) 
# 5.4043 - leptocúrtica

kurtosis(df$edadjef) 
# 2.7270 - platocúrtica

kurtosis(df$añosedu) 
# 3.7990 - leptocúrtica

kurtosis(df$ln_als)
# 6.605526 - leptocúrtica

kurtosis(df$ln_alns)
# 2.5798 - platocúrtica


# 5. Tablas de distribución de frecuencias

# Nivel socioeconómico
freq.nse5f <- table(df$nse5f)
transform(freq.nse5f, 
          rel.freq=prop.table(Freq),
          cum.freq=cumsum(prop.table(Freq)))

ggplot(df, aes(x = nse5f)) +
  geom_bar(color = "darkslategray", fill = "skyblue2", linetype = 0)+
  xlab("Nivel socioeconómico") + 
  ylab("Cantidad de hogares") + 
  ggtitle("Distribución de frecuencias")

# Tipo de área
freq_area <- table(df$area)
transform(freq_area, 
          rel.freq=prop.table(Freq))

ggplot(df, aes(x = area)) +
  geom_bar(color = "darkslategray", fill = "palegreen2", width = .5, linetype = 0)+
  xlab("Tipo de área") + 
  ylab("Cantidad de hogares") + 
  ggtitle("Distribución de frecuencias")

# Recursos financieros adicionales
freq_refin <- table(df$refin)
transform(freq_refin,
          rel.freq=prop.table(Freq))

ggplot(df, aes(x = refin)) +
  geom_bar(color = "darkslategray", fill = "darkgoldenrod2", width = .5, linetype = 0)+
  xlab("Recursos financieros adicionales") + 
  ylab("Cantidad de hogares") + 
  ggtitle("Distribución de frecuencias")

# Sexo del jefe de familia
freq_sexojef <- table(df$sexojef)
transform(freq_sexojef,
          rel.freq=prop.table(Freq))

ggplot(df, aes(x = sexojef)) +
  geom_bar(color = "darkslategray", fill = "indianred2", width = .5, linetype = 0)+
  xlab("Sexo del jefe/a de familia") + 
  ylab("Cantidad de hogares") + 
  ggtitle("Distribución de frecuencias")

# Inseguridad Alimentaria
freq_IA <- table(df$IA)
transform(freq_IA,
          rel.freq=prop.table(Freq))
ggplot(df, aes(x = IA)) +
  geom_bar(color = "darkslategray", fill = "palevioletred2", width = .5, linetype = 0)+
  xlab("Inseguridad Alimentaria - IA") + 
  ylab("Cantidad de hogares") + 
  ggtitle("Distribución de frecuencias")

# Número de personas en el hogar

k = ceiling(1 + 3.3*log10(length(df$numpeho)))
ac = (max(df$numpeho)-min(df$numpeho))/k

bins <- seq(min(df$numpeho), max(df$numpeho), by = ac)

class.numpeho <- cut(df$numpeho, breaks = bins, include.lowest=TRUE, dig.lab = 10)

dist.freq <- table(class.numpeho)
transform(dist.freq, 
          rel.freq=prop.table(Freq), 
          cum.freq=cumsum(prop.table(Freq)))

ggplot(df) + 
  geom_histogram(binwidth = .5, bins = k, aes(x = numpeho), fill = 'steelblue') + 
  xlab("Número de personas en el hogar") + 
  ylab("Cantidad de hogares") + 
  ggtitle("Distribución de frecuencias")


# Edad del jefe/a de familia

k = ceiling(1 + 3.3*log10(length(df$edadjef)))
ac = (max(df$edadjef)-min(df$edadjef))/k

bins <- seq(min(df$edadjef), max(df$edadjef), by = ac)

class.edadjef <- cut(df$edadjef, breaks = bins, include.lowest=TRUE, dig.lab = 10)

dist.freq <- table(class.edadjef)
transform(dist.freq, 
          rel.freq=prop.table(Freq), 
          cum.freq=cumsum(prop.table(Freq)))

ggplot(df) + 
  geom_histogram(bins = k, aes(x = edadjef), fill = 'steelblue') + 
  xlab("Edad del jefe/a de familia") + 
  ylab("Cantidad de hogares") + 
  ggtitle("Distribución de frecuencias")
# binwidth = .5, 

sd(df$añosedu)

# Años de educación del jefe/a de familia

k = ceiling(1 + 3.3*log10(length(df$añosedu)))
ac = (max(df$añosedu)-min(df$añosedu))/k

bins <- seq(min(df$añosedu), max(df$añosedu), by = ac)

class.añosedu <- cut(df$añosedu, breaks = bins, include.lowest=TRUE, dig.lab = 10)

dist.freq <- table(class.añosedu)
transform(dist.freq, 
          rel.freq=prop.table(Freq), 
          cum.freq=cumsum(prop.table(Freq)))

ggplot(df) + 
  geom_histogram( aes(x = añosedu ), fill = 'steelblue') + 
  xlab("Años de educación del jefe/a de familia") + 
  ylab("Cantidad de hogares") + 
  ggtitle("Distribución de frecuencias")


# Logaritmo natural del gasto en alimentos saludables
k = ceiling(1 + 3.3*log10(length(exp(df$ln_als))))
ac = (max(df$ln_als)-min(df$ln_als))/k

bins <- seq(min(df$ln_als), max(df$ln_als), by = ac)

class.ln_als <- cut(df$ln_als, breaks = bins, include.lowest=TRUE, dig.lab = 10)

dist.freq <- table(class.ln_als)
transform(dist.freq, 
          rel.freq=prop.table(Freq), 
          cum.freq=cumsum(prop.table(Freq)))

ggplot(df) + 
  geom_histogram( aes(x = ln_als ), fill = 'steelblue') + 
  xlab("Logaritmo natural del gasto en alimentos saludables") + 
  ylab("Cantidad de hogares") + 
  ggtitle("Distribución de frecuencias")

# binwidth = .1,

# Logaritmo natural del gasto en alimentos no saludables
k = ceiling(1 + 3.3*log10(length(exp(df$ln_alns))))
ac = (max(df$ln_alns)-min(df$ln_alns))/k

bins <- seq(min(df$ln_alns), max(df$ln_alns), by = ac)

class.ln_alns <- cut(df$ln_alns, breaks = bins, include.lowest=TRUE, dig.lab = 10)

dist.freq <- table(class.ln_alns)
transform(dist.freq, 
          rel.freq=prop.table(Freq), 
          cum.freq=cumsum(prop.table(Freq)))

ggplot(df) + 
  geom_histogram(bins=k, aes(x = ln_alns ), fill = 'steelblue') + 
  xlab("Logaritmo natural del gasto en alimentos no saludables") + 
  ylab("Cantidad de hogares") + 
  ggtitle("Distribución de frecuencias")


# 5. Asociacion con la variable dependiente



# 5.1 Correlacion entre variables cuantitativas

dfcorr.select <- select(df, numpeho, edadjef, añosedu, ln_als, ln_alns)
corr_matrix <- round(cor(dfcorr.select),4)
corr_matrix

# TO DO: Interpretación de la matriz


# III. Calcula probabilidades que nos permitan entender el problema en México 
# De acuerdo con la muestra de un total de 20280 hogares, 14427 hogares presentan
# inseguridad alimentaria: 71.13%

14427/20280  
# [1] 0.7113905


# 1. ¿Cuáles son los patrones de gasto en alimentos saludables y no saludables en 
# los hogares mexicanos considerando su nivel socioeconómico, si cuenta con recursos
# financieros extra y si presenta inseguridad alimentaria?


# a) comparar gasto en alimento saludable, con nse, rfin e IA, si las medidas de tendencia
#    central son iguales entre los grupos de nse, por ejemplo, el gasto en alimento
#    saludable no depende del nivel socioeconómico, y así para las otras dos variables y
#    sus grupos

# b) comparar gasto en alimento no saludable


ggplot(df, aes(x=ln_alns, y=nse5f)) +
  geom_boxplot() +
  xlab("Gasto en alimentos no saludables") + 
  ylab("Nivel socioeconómico") + 
  ggtitle("Gasto en alimentos no saludables y nivel Socioeconomico")+
  theme_classic()


ggplot(df, aes(x=ln_alns, y=nse5f, color=IA)) +
  geom_boxplot() +
  xlab("Gasto en alimentos no saludables") + 
  ylab("Nivel socioeconómico") + 
  ggtitle("Gasto en alimentos no saludables y nivel Socioeconomico")+
  theme_classic()

ggplot(df, aes(x=ln_alns, y=refin, color=IA)) +
  geom_boxplot() +
  xlab("Gasto en alimentos no saludables") + 
  ylab("Recursos financieros adicionales") + 
  ggtitle("Gasto en alimentos no saludables y recursos adicionales")+
  theme_classic()


ggplot(df, aes(x=ln_als, y=nse5f)) +
  geom_boxplot() +
  xlab("Gasto en alimentos saludables") + 
  ylab("Nivel socioeconómico") + 
  ggtitle("Gasto en alimentos saludables y nivel Socioeconomico")+
  theme_classic()


ggplot(df, aes(x=ln_als, y=nse5f, color=IA)) +
  geom_boxplot() +
  xlab("Gasto en alimentos saludables") + 
  ylab("Recursos financieros adicionales") + 
  ggtitle("Gasto en alimentos saludables y nivel Socioeconomico")+
  theme_classic()

ggplot(df, aes(x=ln_als, y=refin, color=IA)) +
  geom_boxplot() +
  xlab("Gasto en alimentos saludables") + 
  ylab("Recursos financieros adicionales") + 
  ggtitle("Gasto en alimentos saludables y recursos adicionales")+
  theme_classic()

# 
# 2. ¿Los hogares con menor nivel socioeconómico tienden a gastar más en productos 
#  no saludables que los hogares con mayores niveles socioeconómicos?  
# De acuerdo con las gráficas el nivel socioeconómico medio es en el
# que hay una mayor cantidad de gastos en alimentos no saludables

# 3. ¿El que los hogares con menor nivel socioeconómico gasten más en productos
#  no saludables los lleva a que presente inseguridad alimentaria?
# En las graficas se observa que, en todos los niveles socioeconómicos,
# los hogares con inseguridad alimentaria presentan un gasto mayor
# en alimentos no saludables
#


# IV. Plantea hipótesis estadísticas y concluye sobre ellas para entender el 
# problema en México 

# V. Estima un modelo de regresión, lineal o logístico, para identificar los
# determinantes de la inseguridad alimentaria en México 

attach(df)

logistic.1 <- glm(IA ~ numpeho + edadjef + edadjef:sexojef + 
                    añosedu + añosedu:sexojef, family = binomial)

summary(logistic.1)

pseudo_r2.1 <- (logistic.1$null.deviance - logistic.1$deviance)/logistic.1$null.deviance
pseudo_r2.1

install.packages("caret") 
library(caret)
df$predicho <- as.numeric(logistic.1$fitted.values>=0.5)
df$predicho <- factor(df$predicho, labels = levels(df$IA))
levels(df$predicho)
caret::confusionMatrix(df$predicho, df$IA, positive = "Presenta IA")

# Probablemente los falsos negativos se deben a que eliminiamos cerca del 50% de datos
# incompletos provenientes de los campos de gasto en alimentos saludables/no saludables
# que intervienen en alto grado en la explicación del comportamiento de la inseguridad 
# alimentaria, por lo que sería necesario recabar información acerca de la no
# disponibilidad de estos datos para hacer el tratamiento adecuado de los datos faltantes
# y repetir la modelación para conocer si puede haber un mejor modelo que el obtenido



# VI. Escribe tu análisis en un archivo README.MD y tu código en un script de R y 
# publica ambos en un repositorio de Github.
